import random
from chronometer import Chronometer
import networkx as nx

def _lp_search_helper( g, node, seen_edges = set()):
    # From a starting point node, find the longest
    # path possible in a graph g. We do a depth
    # first search, on all nodes of the graph.

    # From wikipedia : Furthermore, the longest path problem is
    # solvable in polynomial time on any class of graphs with bounded
    # treewidth or bounded clique-width, such as the
    # distance-hereditary graphs. Finally, it is clearly NP-hard on
    # all graph classes on which the Hamiltonian path problem is
    # NP-hard, such as on split graphs, circle graphs, and *** planar
    # graphs. *** => so we're in deep troubles.

    #print(f"node : {node}, {seen_edges}")
    # print(seen_edges)

    best_edges_list = []

    for child in nx.neighbors(g,node):

        if (node,child) not in seen_edges and (child,node) not in seen_edges:
            edge = (node,child)

            se = seen_edges.copy()
            se.add( edge)

            edges_list = [edge] + _lp_search_helper( g, child, se)

            if len(edges_list) > len(best_edges_list):
                best_edges_list = edges_list

    return best_edges_list

def longest_paths_search( graph, randomized = False):
    # This code gives ONE solution (neither the only one,
    # neither the best one) to the problem of finding
    # the minimal set of paths p_i such that union(p_i) = g
    # and intersection(p_x,p_y) == empty for all pairs of x,y
    # (where x != y)

    # We do this by taking an arbitrary point P. Then from
    # P we find the longest path possible. Remove that path
    # from the graph. Now take another P in the graph and
    # start again.

    g = nx.Graph()
    g.update( graph)

    paths = list()

    while g.edges:

        if not randomized:
            arbitrary_node = next(iter(g.edges))[0]
        else:
            arbitrary_node = random.choice( [e for e in g.edges])[0]

        path = _lp_search_helper( g, arbitrary_node)
        paths.append(path)
        g.remove_edges_from( path)
        # for edge in path:
        #     if edge in edges:
        #         edges.remove(edge)
        #     else:
        #         edge = (edge[1], edge[0])
        #         if edge in edges:
        #             edges.remove(edge)
    return paths



if __name__ == "__main__":
    g = nx.Graph()
    g.add_edges_from( [ (1,2), (2,3), (3,1),
                        (7,8), (8,9), (9,7),
                        (1,4),
                        (4,7),
                        (10,11), (12,11), (12,10),
                        (4,5), (5,6), (6,4)
                       ] )


    print("result")

    with Chronometer() as t:
        l_tot = 0
        for p in longest_paths_search(g):
            print(p)
            l = (len(p)+1)*3
            l_tot += l
            print( "{} bytes".format( l))
        print("{} bytes vs {}".format( l_tot, 6*len(g.edges)))
    print("{:0.2f}".format(float(t)))


"""
g.add_edges_from([ (i+1,i+2) for i in range(50) ])

#g.add_edges_from([ (1,2), (2,3), (3,4), (4,1), (1,3) ])
#g.add_edges_from([ (1,2), (2,3), (2,4) ])
# for n in g.nodes:
#     print("{} -> {}".format(n, list(g[n].keys())))

def nij( n,i):
    c = "*abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"[n]
    return f"{c}{i}"

NODES_RANGE = range( 1, len( g.nodes)+2)

for n in g.nodes:
    for j in NODES_RANGE:
        print("(declare-const {} Bool)".format(nij(n,j)))

for n in g.nodes:
    print("(assert (or")
    for j in NODES_RANGE:
        l = [ nij(n,i) for i in NODES_RANGE if j != i]
        l2 = [ nij(o,j) for o in g.nodes if o != n]
        print( "   (and {} (not (or {})) (not (or {})))".format( nij(n,j), " ".join(l), " ".join(l2) ))
    l = [nij(n,i) for i in NODES_RANGE]
    print("   (not (or {}))".format( " ".join(l)))
    print("))")



for j in NODES_RANGE:
    for n in g.nodes:

        l = []
        if j < len( g.nodes)+1:
            l += [nij( d, j+1) for d in g[n].keys()]
        if j > 1:
            l += [nij( d, j-1) for d in g[n].keys()]

        if len(l) > 1:
            text = "(or {})".format( " ".join(l))
        else:
            text = l[0]

        print("(assert (=> {} {}))".format(nij(n,j), text))
    print()

print("(define-fun b2i ((b Bool)) Int (ite b 1 0))")
print("(assert (= (+ {}) 5))".format(" ".join( ["(b2i {})".format(nij(n,j))  for n in g.nodes for j in NODES_RANGE] )))

print("(check-sat)\n(get-model)\n(exit)")
"""
