//
// Created by Valerio on 28/08/2019.
//

#ifndef ALGORITMOS_EM_GRAFOS_GRAPH_H
#define ALGORITMOS_EM_GRAFOS_GRAPH_H

#include <vector>
#include <queue>
#include <utility>
#include <functional>
#include <algorithm>
#include <cmath>


struct Graph {
    int size;

    std::vector<bool> visited;
    std::vector<int> distance;
    std::vector<int> parent;

    std::vector<std::vector<std::pair<int, int>>> adjList;

    explicit Graph(int n){
        size = n;

        visited = std::vector<bool>(n, false);
        distance = std::vector<int>(n, INT32_MAX);
        parent = std::vector<int>(n, -1);
        adjList = std::vector<std::vector<std::pair<int, int>>>(n);
    }

    std::vector<std::pair<int, int>>& operator [](int v){
        return adjList[v];
    }

    void addEdge(int src, int dest, int weight = 0){
        adjList[src].push_back(std::make_pair(dest, weight));
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

    int dijkstra(int src, int dest = -1){
        std::priority_queue<std::pair<int, int>, std::vector<std::pair<int, int>>,
                std::function<bool(std::pair<int, int>, std::pair<int, int>)>> Q([](std::pair<int, int> a, std::pair<int, int> b)->bool{
                    return a.second > b.second;
                });

        std::fill(visited.begin(), visited.end(), false);
        std::fill(distance.begin(), distance.begin(), INT32_MAX);
        std::fill(parent.begin(), parent.end(), -1);

        distance[src] = 0;

        Q.push({src, 0});

        while(!Q.empty()){
            auto u = Q.top().first;
            Q.pop();

            if(u == dest){
                return 1;
            }
            if(!visited[u]){
                visited[u] = true;
                for(auto& edge : adjList[u]){
                    auto v = edge.first;
                    auto w = edge.second;
                    if(distance[u] + w < distance[v]){
                        distance[v] = distance[u] + w;
                        parent[v] = u;
                        Q.push({v, distance[v]});
                    }
                }
            }

            visited[u] = true;
        }

        return 0;
    }

    void tarjan(int src, std::vector<bool> &ap){
        static int time = 0;
        int children = 0;
        int i;

        static std::vector<int> low(size);
        static std::vector<int> disc(size);

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

                low[src]  = std::min(low[src], low[v]);

                if(parent[src] == -1 && children > 1){
                    ap[src] = true;
                }

                if(parent[src] != -1 && low[v] >= disc[src]){
                    ap[src] = true;
                }
            }
            else if(v != parent[src]){
                low[src] = std::min(low[src], disc[v]);
            }
        }
    }

    int fordFulkerson(int s, int t){
        int maxFlow = 0;

        Graph residual(*this);

        while(residual.dijkstra(s, t)){
            int bottleneck = INT32_MAX;

            for(int i = t;i != s;i = residual.parent[i]){
                int j = residual.parent[i];
                int e = residual.getEdgeIndex(j, i);
                if(residual[j][e].second < bottleneck){
                    bottleneck = std::min(bottleneck, residual[j][e].second);
                }
            }

            for(int i = t;i != s;i = residual.parent[i]){
                int j = residual.parent[i];
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

            maxFlow += bottleneck;
        }

        return maxFlow;
    }

    bool bellman_ford(int source){
        std::fill(distance.begin(), distance.end(), INT32_MAX);
        std::fill(parent.begin(), parent.end(), -1);

        distance[source] = 0;

        for(int i = 0;i < size;i++){
            for(int j = 0;j < size;j++){
                for(auto& edge : adjList[j]){
                    if(distance[edge.first] > distance[j] + edge.second){
                        distance[edge.first] = distance[j] + edge.second;
                        parent[edge.first] = j;
                    }
                }
            }
        }

        for(int i = 0;i < size;i++){
            for(auto& edge : adjList[i]){
                if(distance[i] + edge.second < distance[edge.first]){
                    return true;
                }
            }
        }

        return false;
    }
};

#endif //ALGORITMOS_EM_GRAFOS_GRAPH_H
