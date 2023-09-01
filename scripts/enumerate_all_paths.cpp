//compile as:
//g++ -std=c++14 -fmax-errors=1 -O3 -Wall -o enumerate_all_paths enumerate_all_paths.cpp 


#include <vector>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <set>
#include <map> 
#include <unordered_map>
#include <cassert>
#include <cmath>
#include <algorithm>
#include <string>
#include <queue>

using namespace std;


struct Node{
	//string name;
	vector<int> neighbors;
	//double score;

	//computed in the algorithm
	//vector<int> peaks; // indices of accessible peaks
	//vector<double> path; // we use lexicographical order on these values in the alg.  
};



//////////////////////////////////////////////////////////////////////////////////////////


void read_scores(string file_name, vector<double>& scores, vector<string>& node_names) {
	ifstream data_file;
	data_file.open(file_name); 
	string s;
	//data_file >> s >> s;

	cerr << "Reading data" << endl;
	while(true){
		string sseq;
		double val;
		data_file >> sseq >> val;
		if(sseq.size() == 0){
			break;
		}
		scores.push_back(val);
		node_names.push_back(sseq);
	}
	cerr << "Num of nodes: " << scores.size() << endl;
}


void build_graph(vector<Node >& G, vector<string>& node_names, vector<double>& scores, vector<char>& alphabet){
	int pows[4] = {1, 26, 26*26, 26*26*26};
	int hsh[26*26*26*26 + 5];

	for(int j = 0; j < scores.size(); ++j){
		string str = node_names[j];
		int h = 0;
		for(int i = 0; i<str.size(); ++i) {
			h += (str[i]-'A')*pows[i];
		}
		hsh[h] = j;
	}
	
	G.clear();
	G.resize(scores.size(), Node());

	for(int j = 0; j < scores.size(); ++j){
		//G[j].score = scores[j];
		string str = node_names[j];
		int h = 0;
		for(int i = 0; i<str.size(); ++i) {
			h += (str[i]-'A')*pows[i];
		}
		// add neighbors of node j
		for(int it = 0; it < str.size(); ++it){
			for(char c : alphabet){
				if (c != str[it]) {
					int h2 = h + pows[it] * (c - str[it]);
					G[j].neighbors.push_back(hsh[h2]);
				}
			}
		}
	}
}

vector<int> find_peaks(vector<Node>& G, vector<double>& scores){
	int cnt = 0;
	vector<int> peaks;
	//vector<double> peak_scores;

	vector<int> visited(scores.size(), -1);
	vector<pair<double, int> > sorted_seqs;
	for(int i = 0; i < scores.size(); ++i){
		sorted_seqs.push_back({scores[i], i});
	}
	sort(sorted_seqs.begin(), sorted_seqs.end(), greater<>());

	for(int i = 0; i < sorted_seqs.size(); ++i){
		//cout << seq_names[sorted_seqs[i].second] << endl;
		if(visited[sorted_seqs[i].second] == -1){
			// this is a peak
			//cout << "peak" << endl;
			++cnt;
			peaks.push_back(sorted_seqs[i].second);
			//peak_scores.push_back(peak_score);
		}
		for(int v : G[sorted_seqs[i].second].neighbors){
			visited[v] = i;
		}
	}

	return peaks;
}


pair < vector<long long>, vector<long long>> count_accessible_paths(vector<Node>& G, vector<double>& scores, vector<int>& peaks, vector<int>& start_seqs){
	int max_path_length = 15;
	max_path_length++;

	// initialize
	vector<vector<long long>> num_paths(scores.size(), vector<long long>(max_path_length,0));
	for (int i = 0; i<start_seqs.size(); ++i) {
		num_paths[start_seqs[i]][0] = 1;
	}
	
	// sort the nodes by fitness
	vector<pair<double, int> > sorted_seqs;
	for(int i = 0; i < scores.size(); ++i){
		sorted_seqs.push_back({scores[i], i});
	}
	sort(sorted_seqs.begin(), sorted_seqs.end(), less<>());

	for(int i = 0; i < sorted_seqs.size(); ++i){
	//for(int i = 0; i < 2; ++i){
		int curr_v = sorted_seqs[i].second;
		//cout << scores[curr_v] << endl;
		for(int v : G[curr_v].neighbors) {
			//cout << scores[v] << endl;
			if (scores[v] <= scores[curr_v]) {
				//cout << "yes" << endl;
				for (int j = 1; j<max_path_length; ++j) {
					num_paths[curr_v][j] += num_paths[v][j-1];
					//cout << num_paths[curr_v][j] << ",";
				}
				//cout << endl;
			}
		}
	}

	// results
	pair < vector<long long>, vector<long long>> results;
	// global peak
	results.first = num_paths[peaks[0]];
	// sum the vectors for all local peaks
	results.second = vector<long long>(max_path_length,0);
	for (int i = 1; i<peaks.size(); ++i) {
		for (int j = 0; j<max_path_length; ++j) {
			results.second[j] += num_paths[peaks[i]][j];
		}
	}
	return results;

}






int main(int argc, char** argv){
	// command line parameters
	string data_file_str = string(argv[1]);
	//int alphabet_size = atoi(argv[2]);
	string alphabet_str = string(argv[2]);
	string start_seqs_file_str = string(argv[3]);
	string output_file_str = string(argv[4]);
	
		
	// data for the input score
	//read the input score file
	vector<double> scores;
	vector<string> node_names;
	read_scores(data_file_str, scores, node_names);

	
	// the alphabet
	vector<char> alphabet(alphabet_str.begin(), alphabet_str.end());
	int alphabet_size = alphabet.size();

	// the starting sequences of the walks (e.g., the antipodal sequences)
	vector<string> start_seqs;
	ifstream ssfile;
	ssfile.open(start_seqs_file_str);
	while(true){
		string sseq;
		ssfile >> sseq;
		if(sseq.size() == 0){
			break;
		}
		start_seqs.push_back(sseq);
	}
	vector<int> start_seqs_int;
	for (int i = 0; i<start_seqs.size(); ++i) {
		auto it = find(node_names.begin(), node_names.end(), start_seqs[i]);
		int index = it - node_names.begin();
		start_seqs_int.push_back(index);	
	}
	
	// output file
	ofstream out_file;
	out_file.open(output_file_str);

	//the graph we work with
	vector<Node> G;
	build_graph(G, node_names, scores, alphabet);

	vector<int> peaks = find_peaks(G, scores);
	out_file << peaks.size() << "\t";

	pair < vector<long long>, vector<long long>> res = count_accessible_paths(G, scores, peaks, start_seqs_int);
	
	
	
	for(int j =1; j<res.first.size(); ++j) {
		out_file << res.first[j] << "\t";
	}
	for(int j =1; j<res.second.size(); ++j) {
		out_file << res.second[j] << "\t";
	}
	out_file << endl;


}




