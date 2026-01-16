// Made by Aidan Ruck

#include <iostream>
#include <string>
using namespace std;

int main(){
    int position = 50; // Start at 50 (according to prompt)
    int hitsZero = 0;
    string s;

    while(cin >> s){ // Keep taking inputs from file if there are any
        char direction = s[0];
        int distance = stoi(s.substr(1)) % 100; // The input dial will repeat every 100 positions

        if(direction == 'R'){
            position = ((position + distance) % 100);
        }
        else if(direction == 'L'){
            position = ((position - distance + 100) % 100);
        }
        else{
            continue;
            // Ignore blank lines if there are any in the input
        }

        if(position == 0){
            hitsZero++;
        }
    }

    cout << "Password will be: " << hitsZero << endl;
    return 0;
}