//
// Created by Valerio on 28/08/2019.
//

#include <iostream>
#include <Graph.h>


int main(){
    int n, m;
    std::cin >> n >> m;

    Graph G(n);
    std::vector<bool> articulationPoints(n);

    for(int i = 0;i < m;i++){
        int u, v;
        std::cin >> u >> v;
        G.addEdge(u, v);
    }

    std::cout << std::endl;

    for(int i = 0, j = 0;i < n;i++){
        if(articulationPoints[i]){
            if(j){
                std::cout << " ";
            }
            std::cout << i;
            j++;
        }
    }

    std::cout << std::endl;

    return 0;
}
