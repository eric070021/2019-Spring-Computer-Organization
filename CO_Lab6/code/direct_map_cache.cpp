#include <iostream>
#include <math.h>
#include <vector>
#include <utility>

using namespace std;

struct cache_content{
	bool v;
	unsigned int  tag;
	unsigned int  reference;    
};

const int K=1024;

void simulate(int cache_size, int block_size, int associativity){
	unsigned int tag,index,x;

	int offset_bit = (int) log2(block_size);
	int index_bit = (int) log2(cache_size/(block_size*associativity));
	int index_num = cache_size/(block_size*associativity);
	int line= cache_size>>(offset_bit);

	cache_content *cache =new cache_content[line];

	for(int j=0;j<line;j++){
		cache[j].v=false;
		cache[j].reference=0;
	}
	
    FILE * fp=fopen("Trace1.txt","r");					//read file
	vector<int> hit, miss;
	int instruct=0;
	while(fscanf(fp,"%x",&x)!=EOF){
		instruct++;
		index=(x>>offset_bit)&(index_num-1);
		tag=x>>(index_bit+offset_bit);
		bool hit_flag=false;
		int valid=-1;
		for(int i=0;i<associativity;i++){
			valid = cache[index*associativity+i].v?-1:i;
			if(cache[index*associativity+i].v && cache[index*associativity+i].tag==tag){
				hit_flag=true;
				cache[index*associativity+i].reference++;
				hit.push_back(instruct);
			}
		}
		if(!hit_flag){
			miss.push_back(instruct);
			if(valid==-1){
				pair<int,int> lru(0,cache[index*associativity].reference);
				for (int i = 0; i < associativity; i++)
				{
					if(cache[index*associativity+i].reference<lru.second){
						lru.second=cache[index*associativity+i].reference;
						lru.first=i;
					}
				}
				cache[index*associativity+lru.first].v=true;
				cache[index*associativity+lru.first].tag=tag;
				cache[index*associativity+lru.first].reference=1;
			}
			else{
				cache[index*associativity+valid].v=true;
				cache[index*associativity+valid].tag=tag;
				cache[index*associativity+valid].reference=1;
			}
		}
		
	}
	cout<<"Hits instructions: ";
	int i;
	for (i = 0; i < hit.size()-1; i++)
	{
		cout<<hit[i]<<",";
	}
	cout<<hit[i]<<endl;
	cout<<"Misses instructions: ";
	for (i = 0; i < miss.size()-1; i++)
	{
		cout<<miss[i]<<",";
	}
	cout<<miss[i]<<endl;
	double missrate=((miss.size()*100)/(double)(hit.size()+miss.size()));
	cout<<"Miss rate: "<<missrate<<"%"<<endl;
	fclose(fp);
	delete [] cache;
}
	
int main(){
	int cache, block, associativity;
	cout<<"Please input cache size, block size, associativity separated by space: ";
	while(cin>>cache>>block>>associativity){
		simulate(cache*K, block, associativity);
		cout<<"Please input cache size(Kbyte), block size, associativity separated by space: ";
	}
	
	return 0;
}
