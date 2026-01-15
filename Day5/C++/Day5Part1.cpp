// Made by Aidan Ruck
// Advent of Code 2025 Day 5 - C++

#include <iostream>
#include <vector>
#include <string>

using namespace std;

int main(){
    vector<pair<long long,long long>> ranges;
    // Store each range as a pair of integers
    vector<long long> freshIDs;
    // Store fresh ingredients in one long vector
    string line;

    while(getline(cin,line)){
    // Read the fresh ingredient ranges at the top
        bool onlyWhitespace = true;
        for(long long i = 0; i < (long long)line.size(); i++){
            if(line[i] != ' ' && line[i] != '\r' && line[i] != '\t'){
                onlyWhitespace = false;
                break;
            }
        }
        if(onlyWhitespace){
            break;
        }


        size_t dashposition = line.find('-');
        // Look for dash position (middle of range)
        // find() returns a size_t, not an long long
        if(dashposition == string::npos){
            continue;
            //Check for incorrect lines (whitespaces, /r, etc.)
        }
        long long start = stoll(line.substr(0, dashposition));
        long long end = stoll(line.substr(dashposition + 1));
        
        ranges.push_back({start, end});
    }

    while(getline(cin, line)){
        bool whiteSpace = true;
        for(long long i = 0; i < line.size(); i++){
            if(line[i] != ' ' && line[i] != '\r' && line[i] != '\t'){
                whiteSpace = false;
                break;
            }
        }
        if(whiteSpace){
            continue;
        }
        // Skip lines that arent ranges or ingredient ids

        long long id = stoll(line);
        // Convert input string to the ID as an integer
        bool isFresh = false;

        for(long long i = 0; i < ranges.size(); i++){
            long long low = ranges[i].first;
            // Assign bottom of range to first number in vector
            long long high = ranges[i].second;
            // Assign top of range to second number in vector

            if( id >= low && id <= high){
                isFresh = true;
                break;
            }
        }

        if(isFresh){
            freshIDs.push_back(id);
            // Store freshIDs in stack
        }
    }

    cout << "Fresh Ingredient IDs: " << endl;
    for(long long i = 0; i < freshIDs.size(); i++){
        cout << freshIDs[i] << endl;
    }

    cout << "Total Fresh Ingredients: " << freshIDs.size() << endl;

    return 0;
}
