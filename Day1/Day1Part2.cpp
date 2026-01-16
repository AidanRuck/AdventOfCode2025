// Made by Aidan Ruck

#include <iostream>
#include <string>
using namespace std;

int main(){
    long long position = 50; // Swap to long long because the method is no longer contained in integers between 0 and 99
    long long hitsZero = 0;
    string s;

    while(cin >> s){
        char direction = s[0];
        long long distance = stoll(s.substr(1));
        long long fullCycles = distance / 100;
        long long remainder = distance % 100;

        hitsZero += fullCycles;
        // Each 100-click cycle will hit 0 once

        if(remainder > 0 && position != 0){
            long long x;
            if(direction == 'R'){
                x = 100 - position;
            }
            else{
                x = position;
            }

            if(x <= remainder){
                hitsZero++;
            }
        }
        // In less than 100 clicks, you can only hit 0 once

        long long movement = distance % 100;
        if(direction == 'R'){
            position = ((position + movement) % 100);
        }
        else{
            position = ((position - movement + 100) % 100);
        }
    }

    cout << "Password will be: " << hitsZero << endl;
    return 0;
}