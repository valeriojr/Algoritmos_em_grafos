#include <iostream>
#include <cstdio>
#include <vector>
#include <queue>
#include <iostream>
#include <utility>
#include <functional>
#include <algorithm>


#define INF 0x77777777

using namespace std;

struct Graph {
    int size;

    vector<bool> visited;
    vector<int> distance;
    vector<int> parent;

    vector<vector<pair<int, int>>> adjList;

    explicit Graph(int n){
        size = n;

        visited = vector<bool>(n, false);
        distance = vector<int>(n, INF);
        parent = vector<int>(n, -1);
        adjList = vector<vector<pair<int, int>>>(n);
    }

    vector<pair<int, int>>& operator [](int v){
        return adjList[v];
    }

    void addEdge(int src, int dest, int weight){
        adjList[src].push_back(make_pair(dest, weight));
    }

    void removeEdge(int src, int index){
        if (adjList[src].size() > 1) {
            iter_swap(adjList[src].begin() + index, adjList[src].end() - 1);
            adjList[src].pop_back();
        }
        else {
            adjList[src].clear();
        }
    }

    int getEdgeIndex(int src, int dest){
        for(int i = 0;i < adjList[src].size();i++){
            if(adjList[src][i].first == dest){
                return i;
            }
        }

        return -1;
    }

    int dijkstra(int src, int dest){
        priority_queue<pair<int, int>, vector<pair<int, int>>, function<bool(pair<int, int>, pair<int, int>)>> Q([](pair<int, int> a, pair<int, int> b)->bool{
            return a.second > b.second;
        });

        for(int i = 0;i < size;i++){
            visited[i] = 0;
            distance[i] = INF;
            parent[i] = -1;
        }

        distance[src] = 0;

        Q.push({src, 0});

        while(!Q.empty()){
            auto u = Q.top().first;
            Q.pop();

            /*
            cout << "Visiting " << p.first << " with distance " << p.second << endl;
            for(auto& d : distance){
                cout << d << " ";
            }
            cout << endl;
            */

            if(u == dest){
                return 1;
            }
            if(!visited[u]){
                visited[u] = true;
                for(auto& edge : adjList[u]){

                    //cout << "Trying to relax edge " << p.first << "->" << edge.first << "(" << distance[p.first] << "+" << edge.second << " < " << distance[edge.first] << "?)" << endl;
                    auto v = edge.first;
                    auto w = edge.second;
                    if(distance[u] + w < distance[v]){
                        distance[v] = distance[u] + w;
                        parent[v] = u;
                        Q.push({v, distance[v]});

                        //cout << "Pushing " << edge.first << " with distance " << distance[edge.first] << endl;
                    }
                }
            }

            visited[u] = true;
        }

        return 0;
    }

    void tarjan(int src, vector<bool> &ap){
        static int time = 0;
        int children = 0;
        int i;

        static vector<int> low(size);
        static vector<int> disc(size);

        visited[src] = true;

        time++;
        low[src] = time;
        disc[src] = time;


        for(auto& edge : adjList[src]){
            int v = edge.first;
            if(!visited[v]){
                children++;
                parent[v] = src;
                tarjan(v, ap);

                low[src]  = min(low[src], low[v]);

                //printf("Vertex %d has %d child(ren)\n", src, children);

                if(parent[src] == -1 && children > 1){
                    ap[src] = 1;
                    //printf("Aqui %d\n", src);
                }

                if(parent[src] != -1 && low[v] >= disc[src]){
                    ap[src] = 1;
                }
            }
            else if(v != parent[src]){
                low[src] = min(low[src], disc[v]);
            }
        }
    }

    Graph fordFulkerson(int s, int t){
        int max_flow = 0;

        Graph residual(*this);

        while(residual.dijkstra(s, t)){
            int bottleneck = INF;
            int bottleneck_index = -1;

            for(int i = t;i != s;i = residual.parent[i]){
                int j = residual.parent[i];
                int e = residual.getEdgeIndex(j, i);
                if(residual[j][e].second < bottleneck){
                    bottleneck = min(bottleneck, residual[j][e].second);
                    bottleneck_index = e;
                }
            }

            for(int i = t;i != s;i = residual.parent[i]){
                int j = residual.parent[i];
                globalARRAY[i] = j - 1;
                int e = residual.getEdgeIndex(j, i);

                residual[j][e].second -= bottleneck;
                int f = residual.getEdgeIndex(i, j);
                if(f == -1){
                    residual.addEdge(i, j, bottleneck);
                }
                else {
                    residual[i][f].second += bottleneck;
                }
            }

            max_flow += bottleneck;
        }

        return residual;
    }
};

int main() {
    int n, m;
    cin >> n >> m;
    Graph G(n);
    for(int i = 0;i < m;i++){
        int u, v, w;
        cin >> u >> v >> w;
        G.addEdge(u - 1, v - 1, w);
        G.addEdge(v - 1, u - 1, w);
    }

    vector<bool> ap(n, false);
    fill(G.visited.begin(), G.visited.end(), false);
}