#include <bits/stdc++.h>
using namespace std;
int main() {
  int m,n,num,total=0;
  cin>>m>>n;
  for(int i=0;i<n;i++){
    cin>>num;
    total+=num;
  }
  int count=n-1;
  for(int i=0;i<m-1;i++){
    int check=total;
    for(int j=0;j<count;j++){
        cin>>num;
        check-=num;
    }
    cout<<check<<endl;
    total-=check;
    count--;
  }
  return 0;
}
