//
// Created by Valerio on 28/08/2019.
//

#ifndef ALGORITMOS_EM_GRAFOS_UTIL_H
#define ALGORITMOS_EM_GRAFOS_UTIL_H

#include <iostream>
#include <vector>


template <typename T>
std::ostream& operator << (std::ostream& ostream, std::vector<T>& vector){
    ostream << "[";
    for(auto& item : vector){
        ostream << vector;
        if(item != vector.back()){
            ostream << ", ";
        }
    }
    ostream << "]" << std::endl;

    return ostream;
}

#endif //ALGORITMOS_EM_GRAFOS_UTIL_H
