#include <bits/stdc++.h>
using namespace std;

int main(){
	ofstream out;
	out.open("output1.txt");
	out<<"hello\nworld\nand\nhello\nkitty\n";
	out.close();
	out.open("output2.txt");
	out<<"hi\nworld\nand\nkitty\n";
	out.close();
	out.open("output3.txt");
	out<<"hi\nworld\nand\nkitty\n";
	out.close();
	out.open("output4.txt");
	out<<"hi\nworld\nand\nkitty";
	out.close();
}
