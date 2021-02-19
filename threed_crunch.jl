using Dates
using LinearAlgebra

using LightGraphs
using GeometryBasics
using IntervalSets
using Glob
using SimpleDirectMediaLayer
const SDL2 = SimpleDirectMediaLayer
import Base.unsafe_convert


#=
=#

include("intervals.jl")

const X_RES = 256 # 1066 # 256 # 1066
const Y_RES = 192 # 600 # 192 # 600
const EPSILON = 1e-6
const SLEEP = 0.01

POINT_TYPE=Point3{Float64}

DISABLE_CLIPPING=false

mutable struct Segment
  origin::Int
  destination::Int
end


struct Edge
  v1::POINT_TYPE
  v2::POINT_TYPE
end

function ray( edge::Edge)
  return edge.v2 - edge.v1
end

struct Triangle
  a::POINT_TYPE
  b::POINT_TYPE
  c::POINT_TYPE
end


function edges(t::Triangle)
  return [Edge(t.a,t.b); Edge(t.b,t.c); Edge(t.c,t.a)]::Array{Edge,1}
end

function normal( t::Triangle)
  return normalize((t.b-t.a) × (t.c-t.a))
end


struct Face
  vertices::Array{Int,1}
end

function is_edge(f::Face)
  return length(f.vertices == 2)
end

mutable struct PlyMesh
  vertices::Array{POINT_TYPE,1}
  faces::Array{Face,1}
  segments::Array{Segment,1}

  xformed_vertices::Array{POINT_TYPE,1}
  projected_vertices::Array{POINT_TYPE,1}
  perspective_vertices::Array{POINT_TYPE,1}
end

PlyMesh(v,f,s) = PlyMesh(v,f,s,[],[],[])

function Base.getindex(M::PlyMesh, i::Int)
  1 <= i <= M.faces.count || throw(BoundsError(S, i))
  return M.faces[i]
end

function Base.getindex(M::Face, i::Int)
  1 <= i <= length(M.vertices) || throw(BoundsError(M, i))
  return M.vertices[i]
end


function face_normal( mesh::PlyMesh, f::Face)
  a = mesh.vertices[f[1]]
  b = mesh.vertices[f[2]]
  c = mesh.vertices[f[3]]

  normal = (b-a) × (c-a)
  return normal
end

function face_normal(f::Face, vertices::Array{POINT_TYPE,1})
  a = vertices[f[1]]
  b = vertices[f[2]]
  c = vertices[f[3]]

  normal = (b-a) × (c-a)
  return normal
end


function dps(
    graph::SimpleGraph,
    parent_path::Array{Int64,1},
    forbidden_edges::BitArray{2},
    max_depth::Int
)::Array{Int64}

    # print( ne( graph))
    # print(" ")
    # println( length( visited_edges))

    if length( parent_path) == 0

        throw( DomainError( "Don't know where to start !"))

    elseif ne( graph) == 0

        throw( DomainError( "Cannot analyze an empty graph !"))

    elseif length( parent_path) >= max_depth

        return parent_path

    else
        last_vertex = last( parent_path)

        # println(" --- ", last_vertex)
        # println(parent_path)
        # println("nb : ", collect(neighbors( graph, last_vertex)))

        next_vertices =  collect( filter( d -> !forbidden_edges[ last_vertex, d],
                                          neighbors( graph, last_vertex)))

        # println("next : ", next_vertices)
        best_vertices = collect( filter( nv -> nv ∈ parent_path, next_vertices))

        # println("best : ", best_vertices)

        if length( best_vertices) > 0
            next_vertices = best_vertices
        end


        best_path = parent_path
        for next_vertex in next_vertices

            fbe = copy( forbidden_edges)
            fbe[ last_vertex, next_vertex ] = true
            fbe[ next_vertex, last_vertex ] = true

            npath = copy(parent_path)
            push!( npath, next_vertex)

            p = dps(graph, npath, fbe, max_depth)

            if length(p) > length(best_path)
                best_path = p
            end

        end

        return best_path
    end

end

function find_best_path( graph::SimpleGraph, rbase::Int64)
    # rbase is a random base

    # A matrix of boolean, if forbidden_edges[i,j] == true
    # then the i->j edge has been visited.

    forbidden_edges = falses(nv(graph),nv(graph)) # BitArray
    all_paths = []

    while true
        found = false

        # Run through all the edges to find one that has not
        # yet been visited. Its vertices will be the
        # (2) starts of the next search.

        i = j = 1
        ri = 0

        while !found

            ri = ((i + rbase) % nv(graph)) + 1 # +1 'cos 1-based arrays !

            # FIXME i != j or is it ri != j ?
            if i != j && has_edge(graph, ri, j) && forbidden_edges[ri,j] == false
                found = true
                break
            elseif j < nv(graph)
                j += 1
            else
                j = 1

                if i < nv( graph)
                    i += 1
                else
                    break
                end
            end
        end

        max_depth = 20

        if found

            # A non visited edge was found, now let's start searching
            # a new path from its i-vertex.

            np = dps( graph, [ri], forbidden_edges, max_depth)

            # Since i,j is a non visited edge, we're sure that
            # we'll find a path of a length of at least one
            # (the edge itself)

            l1 = length(np)

            # println("len ", length( np))
            if length(np) > 1
                push!( all_paths, np)

                for ndx in 1:(length(np)-1)
                    s = np[ndx]
                    d = np[ndx+1]
                    forbidden_edges[s,d] = true
                    forbidden_edges[d,s] = true
                end
            end

            # We start over but from its j vertex.

            np = dps( graph, [j], forbidden_edges, max_depth)
            l2 = length(np)

            # println("len ", length( np))
            if length(np) > 1
                push!( all_paths, np)

                for ndx in 1:(length(np)-1)
                    s = np[ndx]
                    d = np[ndx+1]
                    forbidden_edges[s,d] = true
                    forbidden_edges[d,s] = true
                end
            end

        else
            break
        end
    end

    return all_paths
end


function optimize_graph( graph)

  best = undef

  # From each vertex, try to build an optimal run
  # of the edges

  for i in 1:nv(graph)
    paths = find_best_path( graph, i)

    if best == undef || length(paths) < length(best)
      best = paths
      #print("!")
    else
      #print(".")
    end

  end

  #println( " --> best len : ",length(best), " for ", ne(graph), " edges, ", nv(graph), " vertices")
  #println( all_paths)

  return best
end


function xclip( a::POINT_TYPE, b::POINT_TYPE)
  if DISABLE_CLIPPING
    return a, b
  end

  bottom = 0
  top = floor(X_RES / 7)*7 - 1

  if a[1] > b[1]
    a,b = b,a
  end

  if a[1] >= top || b[1] < bottom
    return nothing
  end

  d = b-a
  @assert d[1] >= 0

  ca = a
  cb = b

  if abs(d[1]) > 0 # non zero
    s = d[2]/d[1]
    if a[1] < bottom
      ca = POINT_TYPE( bottom,
                       round(a[2] + s*abs(bottom - a[1]),digits=0), 0) # FIXME Sometimes you clear z, sometimes you don't
    end

    if b[1] > top
      cb = POINT_TYPE( top,
                       round(b[2] - s*abs(b[1] - top),digits=0), 0)
    end
  end

  @assert bottom <= ca[1] <= top "$(ca[1])"
  @assert bottom <= cb[1] <= top "$(cb[1])"

  return ca, cb
end


function yclip( a::POINT_TYPE, b::POINT_TYPE)
  if DISABLE_CLIPPING
    return a, b
  end

  bottom = 7
  top = Y_RES - 1 # - 8

  SHRINK = 18 # Not working : 14,16; Working : 12 + 7
  bottom, top = SHRINK, Y_RES - 1 - SHRINK

  if a[2] > b[2]
    a,b = b,a
  end

  if a[2] >= top || b[2] < bottom
    return nothing
  end

  d = b-a
  @assert d[2] >= 0

  ca = a
  cb = b

  if abs(d[2]) > 0 # non zero
    s = d[1]/d[2]
    if a[2] < bottom
      ca = POINT_TYPE( round(a[1] + s*abs(bottom - a[2]),digits=0),
                    bottom, 0)
    end

    if b[2] > top
      cb = POINT_TYPE( round(b[1] - s*abs(b[2] - top),digits=0),
                    top,0)
    end
  end

  @assert 0 <= ca[2] <= Y_RES "$(ca[2])"
  @assert 0 <= cb[2] <= Y_RES "$(ca[2])"
  return ca, cb
end




function bound_by( x, a,b)
  if x < a
    return a
  elseif x > b
    return b
  else
    return x
  end
end


function LinePlaneCollision(planeNormal::POINT_TYPE, planePoint::POINT_TYPE, rayDirection::POINT_TYPE, rayPoint::POINT_TYPE, epsilon=1e-6)

  # from https://rosettacode.org/wiki/Find_the_intersection_of_a_line_with_a_plane#Python

  ndotu = planeNormal ⋅ rayDirection
  if abs(ndotu) < epsilon
    return nothing
  end

  w = rayPoint - planePoint
  si = (planeNormal ⋅ w) * (-1 / ndotu)
  Psi = w + si * rayDirection + planePoint
  return Psi
end


function merge_vertices(mesh::PlyMesh, epsilon = 1e-5)

  # At this point we expct hidden face removal has been completed
  # (so the mesh.face array only contains visible faces) but
  # that the vertices are still the original ones. So there are
  # vertices appearing on visible faces mixed with vertices not
  # appearing anymore. We now clear the latter.

  used_vertices = Set{Int}()
  for face in mesh.faces
    for vi in face.vertices
      push!(used_vertices,vi)
    end
  end

  for s in mesh.segments
    push!(used_vertices,s.origin)
    push!(used_vertices,s.destination)
  end


  unique = Array{POINT_TYPE,1}()
  xfunique = Array{POINT_TYPE,1}()
  projunique = Array{POINT_TYPE,1}()
  perspunique = Array{POINT_TYPE,1}()

  remap = Dict{Int,Int}()

  for vi in used_vertices # 1:length(mesh.vertices) #  #

    # We compare vertices in object space (not in projected space)

    v = mesh.vertices[vi]

    # FIXME Maybe buggy if three or more  vertices must be merged
    # onto the same vertex.

    found = false
    for ui in 1:length(unique)
      if norm(v-unique[ui]) < epsilon
        remap[vi] = ui
        found = true
        break
      end
    end

    if !found
      push!(unique, v)
      push!(xfunique, mesh.xformed_vertices[vi])
      push!(projunique, mesh.projected_vertices[vi])
      push!(perspunique, mesh.perspective_vertices[vi])
      remap[vi] = length(unique)
    end
  end

  mesh.vertices = unique
  mesh.xformed_vertices = xfunique
  mesh.projected_vertices = projunique
  mesh.perspective_vertices = perspunique

  for f in mesh.faces
    for iv in 1:length(f.vertices)
      f.vertices[iv] = remap[f.vertices[iv]]
    end

    # Replacing vertices in a face may lead to
    # a face where some edges disappear...

  end

  for s in mesh.segments
    s.origin = remap[s.origin]
    s.destination = remap[s.destination]
  end


end

function test_merge_vertices()
  mesh = PlyMesh([POINT_TYPE(1.0,23,1.2),
                  POINT_TYPE(1.0,23,1.2000001),
                  POINT_TYPE(1.0,23.0000001,1.2)],
                 [Face([1,2,3])])
  push!(mesh.faces, Face([1,2,3]))
  merge_vertices(mesh)
  println(mesh)
end


#test_merge_vertices()

function load_ply(io::IOStream)
  n_points = 0
  n_faces = 0
  pointtype=POINT_TYPE  # POINT_TYPE

  properties = String[]

  # read the header
  line = readline(io)

  while !startswith(line, "end_header")
    if startswith(line, "element vertex")
      n_points = parse(Int, split(line)[3])
    elseif startswith(line, "element face")
      n_faces = parse(Int, split(line)[3])
    elseif startswith(line, "property")
      push!(properties, line)
    end
    line = readline(io)
  end

  #faceeltype = eltype(facetype)
  points = Array{pointtype}(undef, n_points)
  #faces = Array{FaceType}(undef, n_faces)

  # read the data
  for i = 1:n_points
    points[i] = pointtype(parse.(eltype(pointtype), split(readline(io)))) # line looks like: "-0.018 0.038 0.086"
  end


  #print(points)

  faces = Array{Face,1}()
  segments = Array{Segment,1}()

  for i = 1:n_faces
    line = split(readline(io))
    nb_vertices = parse(Int, popfirst!(line))
    vertices = reinterpret(ZeroIndex{Int}, parse.(Int, line))

    # Check for faces which are long and thin, they will
    # be made edges

    a = points[vertices[1]]
    b = points[vertices[2]]
    c = points[vertices[3]]

    if ((b - a) ⋅ (c - a)) / (norm(b - a) * norm( c - a)) > 0.99
      println("Edge!")

      # Pick the longest
      if norm(b-a) > norm(c-a)
        push!(segments, Segment(vertices[1], vertices[2]))
      else
        push!(segments, Segment(vertices[1], vertices[3]))
      end
    else

      #print(vertices)
      push!(faces, Face(vertices))
      #push!(faces, NgonFace{nb_vertices, faceeltype}()) # line looks like: "3 0 1 3"
    end

  end


  return PlyMesh(points, faces, segments)
end

# using FileIO
# mesh = load_ply("/tmp/Scene_000100.stl")


function hv(v)
  # Vector to homogenous coordinates
  return [v[1]; v[2]; v[3]; 1]::Array{Float64,1}
end

struct Point2D
  x::Int
  y::Int
end

function to_res( c::Float64, res::Int)
  round(Int, (res * c) / 2 + res / 2)
end

function to_res_y( c::Float64, res::Int)
  round(Int, - (res * c) / 2 + res / 2)
end


function xform_vertices(mesh::PlyMesh, view_matrix)

  zs = []

  empty!(mesh.xformed_vertices)
  empty!(mesh.projected_vertices)
  empty!(mesh.perspective_vertices)

  for v in mesh.vertices
    p = view_matrix * hv(v)
    push!(mesh.projected_vertices, POINT_TYPE(p[1],p[2],p[4]))

    z = p[3] / abs(p[4])
    push!(zs, z)

    # if p[3] < 0
    #   println("$(p[3]) / $(p[4]) = $(z)")
    # end


    # This bereaks everything :
    #push!(mesh.xformed_vertices, POINT_TYPE(p[1]/p[4],p[2]/p[4],p[3]))

    p = p / p[4]
    push!(mesh.xformed_vertices, POINT_TYPE(p[1],p[2],p[3]))
    push!(mesh.perspective_vertices, POINT_TYPE(p[1],p[2],p[3]))
  end

  return zs
end

function hidden_faces_removal(mesh::PlyMesh, zs)
  faces = Array{Face,1}()

  for face in mesh.faces
    behind = false
    for vi in face.vertices
      #println(mesh.xformed_vertices[vi][3])
      if zs[vi] < 0.0
        behind = true
        break
      end
    end

    if !behind && face_normal(face, mesh.xformed_vertices)[3] > 0
      push!(faces, face)
    end
  end

  mesh.faces = faces
end


function fusion_edges( mesh::PlyMesh)

  #v = mesh.xformed_vertices
  v = mesh.projected_vertices

  fusioned_edges = Dict{Tuple{Int,Int},Edge}()

  for f in mesh.faces
    for vi in 1:length(f.vertices)
      a = f.vertices[vi]
      b = f.vertices[vi == length(f.vertices) ? 1 : vi + 1]

      if a > b
        a,b=b,a
      end

      fusioned_edges[(a,b)] = Edge(
        v[a],
        v[b])
    end
  end

  for s in mesh.segments

    o, d = s.origin, s.destination
    fusioned_edges[(o,d)] = Edge(
        v[o],
        v[d])
  end

  return fusioned_edges
end

function to_triangles(mesh::PlyMesh)
  atriangles = Array{Triangle,1}()

  #xv = mesh.xformed_vertices
  xv = mesh.projected_vertices

  for face in mesh.faces
    fv = face.vertices

    for i in 2:length(fv) - 1
      push!(atriangles,
            Triangle(xv[fv[1]],
                     xv[fv[i]],
                     xv[fv[i+1]]))
    end

  end

  return atriangles
end


function all_intersects(mesh::PlyMesh)
  eye = POINT_TYPE(0,0,-0) # 0.25

  # At this point, we expect hidden face removal has been
  # done.

  draw_edge = Array{Edge,1}()
  edges = fusion_edges(mesh)
  atriangles = to_triangles(mesh)


  for (vid, edge) in edges
    # Test
    #push!(draw_edge, edge)

    view_triangle = Triangle( eye, edge.v1, edge.v2)

    all_ts = Array{Interval,1}()
    for triangle in atriangles
      # t represents the interval(s) where view_triangle
      # is *hidden* by triangle.
      t = intersect_triangle( view_triangle, triangle)
      if t != nothing
        push!(all_ts, t)
      end
    end

    if length(all_ts) >= 1
      # At least some portions of the possible t are
      # hidden => some may be visible.

      a = [all_ts[1]]
      for i in 2:length(all_ts)
        a = iunion(a, all_ts[i])
      end

      # # Because we use closed intervals, it may be possible
      # # we end up with one-point wide intervals here !
      to_draw = intersect(linvert(a),
                          ClosedInterval(0.0,1.0)) # ~a & portion.closed(0,1)
      # to_draw = intersect(a, Interval(-0.1,1.1)) # ~a & portion.closed(0,1)

      if length(to_draw) > 0
        for i in to_draw
          #println(i)

          edge_start = mesh.perspective_vertices[vid[1]]
          edge_end = mesh.perspective_vertices[vid[2]]
          r = edge_end - edge_start
          v0 = edge_start + r * i.left
          v1 = edge_start + r * i.right

          # v0 = edge.v1 + ray(edge) * i.left
          # v1 = edge.v1 + ray(edge) * i.right

          if true || norm(v0 - v1) > 0.001
            push!( draw_edge, Edge(v0,v1))
          end
        end
      end

    else
      # Nothing is invisble => everything is visible
      if true || norm(ray(edge)) > 0.001
        edge_start = mesh.perspective_vertices[vid[1]]
        edge_end = mesh.perspective_vertices[vid[2]]
        push!(draw_edge, Edge(edge_start, edge_end))
        #push!(draw_edge, edge)
      end
    end
  end

  return draw_edge
end



# function draw_edges( mesh::PlyMesh, view_matrix, renderer)
#   for f in mesh.faces

#     normal = face_normal(mesh,f) * 0.5
#     base = mesh.vertices[f[1]]
#     for v in f.vertices[2:end]
#       base = base + mesh.vertices[v]
#     end
#     base = (1.0/length(f.vertices)) * base

#     na = view_matrix * hv(base)
#     nb = view_matrix * hv(base + normal)
#     n1 = Point2D( to_res(na[1] / na[4], X_RES), to_res_y(na[2] / na[4],Y_RES))
#     n2 = Point2D( to_res(nb[1] / nb[4], X_RES), to_res_y(nb[2] / nb[4],Y_RES))

#     #visible = (view_matrix*hv(base + normal) - view_matrix*hv(base))[3] < 0

#     # nz = [normal[1]; normal[2]; normal[3]; 0]
#     # visible = (view_matrix*hv(nz))[3] < 0

#     visible = face_visible(mesh,f,view_matrix)

#     SDL2.SetRenderDrawColor(renderer, 255, 0, 0, 255)

#     SDL2.RenderDrawLine(renderer,n1.x,n1.y,n2.x,n2.y)

#     SDL2.SetRenderDrawColor(renderer, 255, 255, 255, 255)
#     if visible
#       for vi in 1:length(f.vertices)

#         a = mesh.xformed_vertices[f[vi]]
#         p1 = Point2D( to_res(a[1], X_RES),
#                       to_res_y(a[2],Y_RES))

#         vi2 = vi % length(f.vertices) + 1
#         a = mesh.xformed_vertices[f[vi2]]
#         p2 = Point2D( to_res(a[1], X_RES),
#                       to_res_y(a[2],Y_RES))

#         SDL2.RenderDrawLine(renderer,p1.x,p1.y,p2.x,p2.y)
#       end

#     end
#   end
# end




function intersect(tri::Triangle, r::Edge)

  ERROR = nothing

  v0 = tri.a
  v1 = tri.b
  v2 = tri.c

  v0v1 = v1 - v0
  v0v2 = v2 - v0
  pvec = cross(ray(r),v0v2)
  det = v0v1 ⋅ pvec # Dot product

  if det > -EPSILON && det < EPSILON
    return ERROR
  end

  invDet = 1 / det
  tvec = r.v1 - v0
  u = (tvec ⋅ pvec) * invDet # dot product then scalar product

  if u < -EPSILON || u > 1 + EPSILON
    # print( f"bad   u:{u}")
    return ERROR
  end

  qvec = cross(tvec,v0v1)
  v = (ray(r) ⋅ qvec) * invDet

  if v < 0 - EPSILON || u + v > 1 + EPSILON
    # print( f"bad v u:{u}, u:{v}")
    return ERROR
  end

  t = (v0v2 ⋅ qvec) * invDet
  #assert not math.isnan(t) and not math.isnan(u) and not math.isnan(v)
  return ( t,u,v)

end


function all_edges_intersections( tri::Triangle, edges::Array{Edge,1})

  # print(f"all_edges_intersections : {tri}")
  intersections = Array{POINT_TYPE,1}()

  for edge in edges
    res = intersect(tri, edge)

    if res != nothing
      t,u,v = res

      if abs(t) < EPSILON
        t = 0
      elseif abs(t-1) < EPSILON
        t = 1
      end

      if 0 <= t <= 1
        inter = edge.v1 + (t * ray(edge))
        push!(intersections, inter)
      end
    end
  end

  return intersections
end

function intersect_triangle( view_tri::Triangle, tri::Triangle)

  # The view triangle is the one defined by a vertex located at the
  # view point (A) and a segment of which we're interested in computing
  # the visibility (BC).

  # We'll intersect that view triangle with all other triangles in
  # the scene.

  # The intersection between view triangle and another triangle is
  # made of 0,1 or 2 points of intersection. 0 means no intersection,
  # 1 means both triangle are just touching each other in a locus made
  # of one point, 2 means there's an intersection locus made of a
  # segment.

  # Given an intersection segment, I1-I2, we're interested in
  # knowing how much of BC is hidden. To to that we simply
  # project I1 on BC along A-I1 (let P1 that point)  and I2 on
  # BC along A-I2 (P2).

  # At this point we know that BC minus P1P2 is visible and
  # that BP1 an P2C are the visible parts (provided P1 is closer
  # to B than P2, which depends on the triangle positions).

  # print("---------- intersect_triangle")

  intersections1 = all_edges_intersections( tri, edges(view_tri))
  intersections2 = all_edges_intersections( view_tri, edges(tri))

  # println(intersections1)
  # println(intersections2)

  intersections = vcat(intersections1,intersections2)

  #print(f"self collisions {inter}, t={t} between edge {self_edge} and {tri}")

  # Now I project each intersection along a line
  # A (= self.a) - I on the segment BC (so basically, I compute
  # the intersection between AI and BC.
  # I cannot compute the intersection directly because
  # I fear rounding errors that could lead to AI and BC
  # to not intersect at all.
  #
  # So I do it by computing the intersection between
  # a plane orthogonal to ABC, passing through IA
  # and BC.

  inter_ts = Array{Float64,1}()
  ab = view_tri.b - view_tri.a
  ac = view_tri.c - view_tri.a
  bc = Edge( ab, ac)

  special_t_0 = false
  special_t_1 = false

  for inter in intersections

    if norm(inter - view_tri.b) < 1e-6
      special_t_0 = true
      continue
    elseif norm(inter - view_tri.c) < 1e-6
      special_t_1 = true
      continue
    end


    # All vectors are relative to A

    ai = inter - view_tri.a

    iplane_org = ai
    iplane_norm_base = cross( ai, normal(view_tri))
    iplane_norm = normalize(iplane_norm_base)

    edge_inter = LinePlaneCollision( iplane_norm, iplane_org, ray(bc), bc.v1)
    #print( edge_inter)

    if edge_inter == nothing
      #continue

      # print("{self}")
      # print("{tri}")

      # print( iplane_org)
      # print( iplane_norm)
      # print( "bc.orig = {bc.orig}")
      # print( "bc.ray  = {bc.ray}")

      throw(DomainError(edge_inter, "was expecting an intersection"))
    end

    @assert norm(ray(bc)) > 0
    t = (edge_inter - ab) ⋅ ray(bc) * (1/(norm(ray(bc)) ^ 2))
    #print(t)
    if isnan(t)
      println("---Error!")
      println("edge_inter = org:$(edge_inter) ab:$(ab) ai:$(ai)")
      println("iplane_norm:$(iplane_norm) iplane_org:$(iplane_org) -- norm_base:$(iplane_norm_base) ")
      println("bc = org:$(bc.v1) -- ray:$(ray(bc))")
      println("view tri normal : $(normal(view_tri))")
      println("view tri : $(view_tri)")

      println("$(tri)")
      println("inter: $(inter) - view_tri.a : $(view_tri.a)")
      println("iplane = org:$(iplane_org) -- norm_base:$(iplane_norm_base) norm:$(iplane_norm)")

      throw(DomainError(t,"NaN spotted"))
    end

    # if abs(t) < EPSILON
    #   t = 0
    # elseif abs(1-t) < EPSILON
    #   t = 1
    # else
    #   t = bound_by(t,0,1)
    # end

    t = bound_by(t,0,1)

    push!(inter_ts,t)

  end

  if length(inter_ts) == 0
    return nothing
  elseif length(inter_ts) == 1
    # At least one real intersection
    if special_t_0
      push!(inter_ts,0)
    elseif special_t_1
      push!(inter_ts,1)
    end
  end


  if !(length(inter_ts) == 0 || length(inter_ts) >= 2)
    # println("\nUnexpected number of intersections : {len(inter_ts)}. View-tri {view_tri}; other-tri : {tri}")
    # println("Special t : {special_t_0} {special_t_1}")
    # println("Intersections 1 : {}".format( [str(i) for i in intersections1]))
    # println("Intersections 2 : {}".format( [str(i) for i in intersections2]))

    throw(DomainError(length(inter_ts), "Bad length"))

    inter_ts = []
  end



  if length(inter_ts) > 0
    inter_ts = [t for t in sort(inter_ts)]

    cleaned_ts = [ inter_ts[1] ]
    for i in 2:length( inter_ts)
      if abs(inter_ts[i] - cleaned_ts[end]) > EPSILON
        @assert !isnan( inter_ts[i] )
        push!(cleaned_ts, inter_ts[i] )
      end
    end

    # if !(length( cleaned_ts) in (1, 2))
    #   return nothing
    # end


    @assert length( cleaned_ts) in (1, 2) "unexpected length : $(length( cleaned_ts))"
    if length( cleaned_ts) == 1
      return nothing
    end

    @assert cleaned_ts[1] < cleaned_ts[2] "$(cleaned_ts[1]) >? $(cleaned_ts[2]) -- $(inter_ts)"
    # Invisible t's interval
    t_interval = ClosedInterval( cleaned_ts[1], cleaned_ts[2])

    #println( "returning : $(t_interval)")
    return t_interval
  else
    return nothing
  end
end


function clip_edges(drawn_edges)
  final_edges = []

  for edge in drawn_edges

    # p1 = Point2D( to_res(edge.v1[1], X_RES),
    #               to_res_y(edge.v1[2], Y_RES))
    # p2 = Point2D( to_res(edge.v2[1], X_RES),
    #               to_res_y(edge.v2[2],Y_RES))

    p1 = POINT_TYPE( to_res(edge.v1[1], X_RES),
                     to_res_y(edge.v1[2], Y_RES),
                     0)
    p2 = POINT_TYPE( to_res(edge.v2[1], X_RES),
                     to_res_y(edge.v2[2],Y_RES),
                     0)

    c = xclip(p1,p2)
    if c != nothing
      c = yclip(c[1],c[2])

      if c != nothing
        p1, p2 = c

        p1 = Point2D(round(p1[1]),round(p1[2]))
        p2 = Point2D(round(p2[1]),round(p2[2]))

        if sqrt((p1.x-p2.x) ^ 2 + (p1.y-p2.y) ^ 2) >= 2
          push!(final_edges, (p1,p2))
        end
      end
    end
  end

  return final_edges
end


function draw_edges(renderer, edges)
  SDL2.SetRenderDrawColor(renderer, 255, 255, 255, 255)
  for (p1,p2) in edges
    SDL2.RenderDrawLine(renderer,p1.x,p1.y,p2.x,p2.y)
  end
end


function edges_to_graph(frame_lines)
  points = Dict()
  edges = Set{Tuple{Int,Int}}()
  ndx_to_point = Dict{Int,Tuple{Int,Int}}()

  uedges = []

  for edge in frame_lines

    ax, ay = edge[1].x, edge[1].y
    bx, by = edge[2].x, edge[2].y

    # The +1 is necessay, FIXME why ?
    # without it the graph records *less* edges !
    if !haskey(points, (ax,ay))
      points[(ax,ay)] = length(points)+1
      ndx_to_point[points[(ax,ay)]] = (ax,ay)
    end
    a = points[(ax,ay)]

    if !haskey(points, (bx,by))
      points[(bx,by)] = length(points)+1
      ndx_to_point[points[(bx,by)]] = (bx,by)
    end
    b = points[(bx,by)]

    @assert a != b
    if a > b
      a,b=b,a
    end

    if !( (a,b) in edges)
      push!(edges, (a,b) )
      push!(uedges, edge)
    end

  end

  g = Graph(length(points))
  for e in edges
    add_edge!(g,e)
  end

  # for e in LightGraphs.edges(g)
  #   println(e)
  # end
  # println(edges)

  return ndx_to_point, points, uedges, g
end


function save_frames_edges(frames, best_paths)
  open("/tmp/edges.txt","w") do output
    for edges in frames
      for edge in edges
        print(output, "$(edge[1].x) $(edge[1].y) $(edge[2].x) $(edge[2].y), ")
      end
      println(output, )
    end
  end

  open("/tmp/cedges.txt","w") do output
    for frame_best_paths in best_paths
      s = join(["$(b)" for b in frame_best_paths], ",")
      println(output, s)
      #println(s)
    end
  end

end


function path_to_bytes( paths, ndx_to_point)
  if length(paths) == 0
    println("Empty paths in this frame ?")
    return nothing
  end

  bytes = Array{Int,1}()

  push!(bytes, length(paths))
  for path in paths
    if length(path) >= 1
      push!(bytes, length(path) - 1) # number of edges, not number of vertices

      for i in path
        p = ndx_to_point[i]
        @assert DISABLE_CLIPPING || 0 <= p[1] <= min(255, X_RES-1) "$(p[1]) is wrong"
        @assert DISABLE_CLIPPING || 0 <= p[2] <= min(255, Y_RES-1) "$(p[2]) is wrong"
        push!(bytes, p[1])
        push!(bytes, p[2])
      end
    else
      print("Empty path !")
    end
  end
  return bytes
end


# intersect_triangle(
#   Triangle(POINT_TYPE(-1,-1,0),POINT_TYPE(+1,-1,0),POINT_TYPE(0,+1,0)),
#   Triangle(POINT_TYPE(0,-1,-1),POINT_TYPE(0,+1,-1),POINT_TYPE(0,0,+1)))

function animate()
  view_matrix = [ 1.9053 2.0213  0.0000 -0.0219;
                  -1.6001 1.5083  4.4217  0.2964;
                  -0.6529 0.6154 -0.4462 11.0785;
                  -0.6516 0.6142 -0.4453 11.2562]::Array{Float64,2}

  # view_matrix = [1.9053350687026978 -1.6000666618347168 -0.6528627276420593 -0.6515582799911499;
  #                2.0213232040405273 1.5082511901855469 0.6154000163078308 0.6141704320907593;
  #                4.139211640108442e-8 4.4217071533203125 -0.4461628794670105 -0.44527143239974976;
  #                2.501056671142578 -0.03383829444646835 10.94376277923584 11.121697425842285]::Array{Float64,2}

  win = SDL2.CreateWindow("Hello World!", Int32(1), Int32(1), Int32(X_RES), Int32(Y_RES),
                          UInt32(SDL2.WINDOW_SHOWN))
  renderer = SDL2.CreateRenderer(win, Int32(-1),
                                 UInt32(SDL2.RENDERER_ACCELERATED | SDL2.RENDERER_PRESENTVSYNC))  # | SDL2.RENDERER_PRESENTVSYNC

  all_frames_edges = []
  all_frames_paths = []

  try
    for fname in glob("Scene_*.ply","/tmp")

      SDL2.SetRenderDrawColor(renderer, 0,0,0,0)
      SDL2.RenderClear(renderer)

      let mesh, camera
        open(fname,"r") do input
          mesh = load_ply(input)
        end

        cfile = replace(fname, "ply" => "cam")
        open(cfile, "r") do input
          line = readline(input)
          s = String.(split(strip(line)[2:end-1],", "))
          a = [parse(Float64,x) for x in s]

          line = readline(input)
          s = String.(split(strip(line)[2:end-1],", "))
          b = [parse(Float64,x) for x in s]

          line = readline(input)
          s = String.(split(strip(line)[2:end-1],", "))
          c = [parse(Float64,x) for x in s]

          line = readline(input)
          s = String.(split(strip(line)[2:end-1],", "))
          d = [parse(Float64,x) for x in s]

          view_matrix = transpose([a b c d]::Array{Float64,2})
        end

        ts = now()

        zs = xform_vertices(mesh, view_matrix)
        hidden_faces_removal(mesh, zs)
        merge_vertices(mesh)
        drawn_edges = all_intersects(mesh)
        final_edges = clip_edges(drawn_edges)

        if length(final_edges) >= 1
          draw_edges(renderer,final_edges)
          ndx_to_point, final_points, final_edges, graph = edges_to_graph(final_edges)
          best_paths = optimize_graph(graph)

          #println(now() - ts)


          bytes = path_to_bytes( best_paths, ndx_to_point)
          if bytes != nothing
            push!(all_frames_edges, final_edges)
            push!(all_frames_paths, path_to_bytes( best_paths, ndx_to_point))
          end


          println("F:$(length(mesh.faces)) V:$(length(mesh.vertices)) xfV:$(length(mesh.xformed_vertices)) edges:$(length(final_edges)) g_edges:$(ne(graph)) g_vtx:$(nv(graph))")
        end
      end

      SDL2.RenderPresent(renderer)
      sleep(SLEEP)
    end
  catch e
     @error "Something went wrong" exception=(e, catch_backtrace())
  end



  SDL2.DestroyRenderer(renderer)
  SDL2.DestroyWindow(win)
  SDL2.Quit()

  save_frames_edges(all_frames_edges, all_frames_paths)

end

animate()
# print(now())
# for i in 1:100

#   SDL2.SetRenderDrawColor(renderer, 0,0,0,0)
#   SDL2.RenderClear(renderer)
#   SDL2.SetRenderDrawColor(renderer, 255, 255, 255, 255)

#   for j in length(mesh)
#     tr = mesh[j]

#     for edge in 1:3
#       a = tr[edge]
#       b = tr[edge % 3]
#       SDL2.RenderDrawLine(renderer,0,600,800,0)
#     end

#   end




# end
# print(now())


# SDL2.FreeSurface(surface)




# # ## header to provide surface and context
# # using Cairo

# # c = CairoRGBSurface(256,256);
# # cr = CairoContext(c);

# # save(cr);
# # set_source_rgb(cr,0.8,0.8,0.8);    # light gray
# # rectangle(cr,0.0,0.0,256.0,256.0); # background
# # fill(cr);
# # restore(cr);

# # ## original example, following here
# # xc = 128.0;
# # yc = 128.0;
# # radius = 100.0;
# # angle1 = 45.0  * (pi/180.0);  # angles are specified
# # angle2 = 180.0 * (pi/180.0);  # in radians

# # set_line_width(cr, 10.0);
# # arc(cr, xc, yc, radius, angle1, angle2);
# # stroke(cr);

# # # draw helping lines
# # set_source_rgba(cr, 1, 0.2, 0.2, 0.6);
# # set_line_width(cr, 6.0);

# # arc(cr, xc, yc, 10.0, 0, 2*pi);
# # fill(cr);

# # arc(cr, xc, yc, radius, angle1, angle1);
# # line_to(cr, xc, yc);
# # arc(cr, xc, yc, radius, angle2, angle2);
# # line_to(cr, xc, yc);
# # stroke(cr);

# # ## mark picture with current date
# # move_to(cr,0.0,12.0);
# # set_source_rgb(cr, 0,0,0);
# # show_text(cr,Libc.strftime(time()));
# # write_to_png(c,"sample_arc.png");
# unsafe_convert(::Type{Ptr{SDL2.RWops}}, s::String) = SDL2.RWFromFile(s, "rb")
# surface = SDL2.IMG_LoadPNG_RW("sample_arc.png")
# # Doesn't work
# # tex = SDL2.CreateTextureFromSurface(renderer, surface)
# # unsafe_convert(::Type{Ptr{SDL2.Rect}}, s::Int64) = SDL2.RenderCopy(renderer, tex, 0, 0)
