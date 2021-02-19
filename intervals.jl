using IntervalSets

const LEFT=1
const RIGHT=2

function inv_closedness(i,end_)
  return closedendpoints(i)[end_] ? :open : :closed
end

function closedness(i,end_)
  return closedendpoints(i)[end_] ? :closed : :open
end

function invert(a::Interval)

  left = nothing
  right = nothing

  if a.left == -Inf && a.right == Inf
    return nothing
  elseif a.left == -Inf
      return Interval{inv_closedness(a,RIGHT),:open}(a.right,+Inf)
  elseif a.right == +Inf
      return Interval{:open,inv_closedness(a,LEFT)}(-Inf,a.left)
  else
    b = Interval{:open,inv_closedness(a,LEFT)}(-Inf,a.left)
    c = Interval{inv_closedness(a,RIGHT),:open}(a.right,+Inf)

    return (b,c)
  end
end


function intersect(a::Interval, b::Interval)

  left, right = nothing, nothing
  left_open, right_open = nothing, nothing

  if a.left ∈ b
    left = a.left
    left_open = closedness(a,LEFT)
  end

  if a.right ∈ b
    right = a.right
    right_open = closedness(a,RIGHT)
  end

  if b.left ∈ a
    left = b.left
    left_open = closedness(b,LEFT)
  end

  if b.right ∈ a
    right = b.right
    right_open = closedness(b,RIGHT)
  end

  if left != nothing && right != nothing
    return Interval{left_open, right_open}(left, right)
  else
    throw( ArgumentError("Cannot intersect disjoint intervals $(a) $(b)"))
  end
end

function covers_helper(a::Interval, b::Interval)
  res = false

  x = leftendpoint(a)
  xc = closedness(a,LEFT) == :closed
  #println("left: $(x) $(xc) $(closedendpoints(a)) $(closedness(a,LEFT))")
  if x == leftendpoint(b)
    return true
  elseif x == rightendpoint(b)
    return xc && closedness(b,RIGHT) == :closed
  else
    res = res || x ∈ b
  end

  x = rightendpoint(a)
  xc = closedness(a,RIGHT) == :closed
  #println("right: $(x) $(xc)")

  if x == leftendpoint(b)
    return xc && closedness(b,LEFT) == :closed
  elseif x == rightendpoint(b)
    return true
  else
    res = res || x ∈ b
  end

  return res
end


function covers(a::Interval, b::Interval)
  # true if a covers partially or completely b

  return covers_helper(a,b) || covers_helper(b,a)
end


function iunion( list::Array{T,1}, itv::T) where {T <: Interval}
  #println("0:")
  is_valid(list)

  for a in list
    if covers(a,itv)
      itv = union(a,itv)
    end
  end

  #println("0:")

  new_list = Array{Interval,1}()

  i = 1
  while i <= length(list) && leftendpoint(list[i]) < leftendpoint(itv)
    #println("1: $(i)")
    if !covers(list[i],itv)
      push!(new_list,list[i])
    end
    i = i + 1
  end

  push!(new_list, itv)

  while i <= length(list)
    #println("2: $(i)")
    if !covers(list[i],itv)
      push!(new_list,list[i])
    end
    i = i + 1
  end

  return new_list
end

function is_valid(list::Array{T,1}) where {T <: Interval}

  if length(list) > 0
    for i in 2:length(list)
      @assert leftendpoint(list[i-1]) <= leftendpoint(list[i]) "$(list)"
      @assert !covers(list[i-1],list[i]) "$(list)"
    end
  end
end

function intersect( list::Array{T,1}, a::Interval) where {T <: Interval}

  nu = Array{Interval,1}()
  for i in list
    if covers(a,i)
      push!(nu, intersect(a,i))
    end
  end

  return nu
end

function linvert( list::Array{T,1}) where {T <: Interval}
  is_valid(list)

  if length(list) == 0
    return [OpenInterval(-Inf,+Inf)]
  end

  # Assuming list is sorted according to leftendpoint(itv)
  # Assuming intervals are all disjoint

  all = Array{Interval,1}()

  left = -Inf
  left_open = :open

  for i in list
    right = leftendpoint(i)
    right_open = inv_closedness(i,LEFT)

    if left != right
      push!(all, Interval{left_open,right_open}(left,right))
    end


    left = rightendpoint(i)
    left_open = inv_closedness(i,RIGHT)
  end

  right = +Inf
  right_open = :open
  if left != right
    push!(all, Interval{left_open,right_open}(left,right))
  end


  return all
end


function test()
  a = ClosedInterval(1,5)
  inv_a1, inv_a2 = invert(a)
  @assert inv_a1.left == -Inf
  @assert inv_a1.right == 1
  @assert inv_a2.left == 5
  @assert inv_a2.right == +Inf

  r = linvert(Array{Interval,1}())
  @assert length(r) == 1 && r[1].left == -Inf && r[1].right == + Inf

  r = linvert([OpenInterval(-Inf,+Inf)])
  @assert length(r) == 0 "$(r)"

  r = linvert([OpenInterval(0,1)])
  @assert length(r) == 2 "$(r)"

  r = linvert([ClosedInterval(0,1),ClosedInterval(2,3)])
  @assert length(r) == 3 "$(r)"

  r = linvert(linvert([ClosedInterval(0,1),ClosedInterval(2,3)]))
  @show r
  @assert length(r) == 2 "$(r)"

  # Unions

  b = ClosedInterval(1,10)
  @show iunion([b], ClosedInterval(-10,1))
  @show iunion([b], ClosedInterval(-10,5))
  @show iunion([b], ClosedInterval(-10,10))
  @show iunion([b], ClosedInterval(-10,12))

  b = ClosedInterval(1,2)
  c = ClosedInterval(3,4)
  d = ClosedInterval(5,6)



  @show iunion(Array{Interval,1}(), a)
  @show iunion([b; c; d], a)
  @show iunion([c; d], b)
  @show iunion([b; c], d)
  @show iunion([b; d], c)

  b = ClosedInterval(1,1)
  c = ClosedInterval(2,2)
  @show iunion([b], c)
  @show iunion([c], b)


  # Covering

  b = ClosedInterval(1,2)
  c = ClosedInterval(3,4)
  @assert !covers(b,c)
  @assert !covers(c,b)

  c = OpenInterval(1,2)
  @assert covers(b,c)
  @assert covers(c,b)

  b = ClosedInterval(1,2)
  c = ClosedInterval(2,3)
  @assert covers(b,c)
  @assert covers(c,b)

  b = OpenInterval(1,2)
  c = ClosedInterval(2,3)
  @assert !covers(b,c)
  @assert !covers(c,b)

  b = OpenInterval(1,2)
  c = OpenInterval(2,3)
  @assert !covers(b,c)
  @assert !covers(c,b)

  b = ClosedInterval(1,2)
  c = OpenInterval(2,3)
  @assert !covers(b,c)
  @assert !covers(c,b)

  # partly covers
  b = ClosedInterval(1,2)
  c = OpenInterval(1.5,3)
  @assert covers(b,c)
  @assert covers(c,b)

  # completely covers
  b = ClosedInterval(0,100)
  c = OpenInterval(1.5,3)
  @assert covers(b,c)
  @assert covers(c,b)
end
