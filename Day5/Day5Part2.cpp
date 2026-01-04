// Made by Aidan Ruck
// Advent of Code 2025 Day 5 - C++

#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

using namespace std;

int main(){
    vector<pair<long long, long long>> ranges;
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
        if(dashposition == string::npos){
            continue;
        }

        long long start = stoll(line.substr(0, dashposition));
        long long end = stoll(line.substr(dashposition + 1));
        
        ranges.push_back({start, end});
    }
    // This block of code is the same as Part 1.

    if(ranges.empty()){
        cout << 0 << endl;
        return 0;
        // If no ranges, end program
    }

    sort(ranges.begin(), ranges.end());
    //Sort by their starts then ends

    long long totalFreshIDs = 0;
    long long currentLeft = ranges[0].first;
    long long currentRight = ranges[0].second;
    // Create trackers

    for(int i = 1; i < (int)ranges.size(); i++){
        long long left = ranges[i].first;
        long long right = ranges[i].second;
        // Gather next range

        if(left <= currentRight + 1){
            if(right > currentRight){
                currentRight = right;
                // If the boundaries are overlapping or the same, merge the two together
            }
        }
        else{
            totalFreshIDs += (currentRight - currentLeft + 1);
            currentLeft = left;
            currentRight = right;
            // Finalize merges
        }
    }

    totalFreshIDs += (currentRight - currentLeft + 1);
    // If the last input ran should merge, ensure that it happens
    // Also, run again for posterity sake

    cout << "Total amount of Fresh IDs: " << totalFreshIDs << endl;
    
    return 0;
}
