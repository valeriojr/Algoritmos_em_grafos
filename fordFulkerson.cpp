//
// Created by Valerio on 28/08/2019.
//

#include <iostream>
#include <Graph.h>
#include <util.h>


int main(){
    int n, m, s, t;
    std::cin >> n >> m;

    Graph G(n);

    for(int i = 0;i < m;i++){
        int u, v, w;
        std::cin >> u >> v >> w;
        G.addEdge(u, v, w);
    }

    std::cin >> s >> t;

    std::cout << G.fordFulkerson(s, t) << std::endl;

    return 0;
}
