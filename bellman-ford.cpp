#include <cstdio>
#include <vector>
#include <iostream>
#include <utility>
#include <queue>

using namespace std;

#define INF 0x77777777

typedef vector<vector<pair<int, int>>> Graph;


int bellman_ford(Graph& G, int source){
    vector<int> distance(G.size(), INF);
    vector<int> parent(G.size(), -1);

    distance[source] = 0;

    for(int i = 0;i < G.size();i++){
        for(int i = 0;i < G.size();i++){
            for(auto& edge : G[i]){
                if(distance[edge.first] > distance[i] + edge.second){
                    distance[edge.first] = distance[i] + edge.second;
                    parent[edge.first] = i;
                }
            }
        }
    }

    for(int i = 0;i < G.size();i++){
        for(auto& edge : G[i]){
            if(distance[i] + edge.second < distance[edge.first]){
                return 1;
            }
        }
    }

    return 0;
}

int main() {
    int n, m;
    cin >> n >> m;
    Graph G(n);

    for(int i = 0;i < m;i++){
        int u, v, w;
        cin >> u >> v >> w;
        G[u].push_back({v, w});
    }

    if(!bellman_ford(G, 0)){
        cout << "not possible" << endl;
    }
    else {
        cout << "possible" << endl;
    }

    return 0;
}