#include <iostream>

#include "FixedPoint/FP32.h"
#include "FixedPoint/FP64.h"

using namespace std;

int main() {
	cout << "test main begin" << endl;

	common::FP64 v(0);
	auto r = v + 100000;
	cout << r.sqrt().toNumber() << endl;
	return 0;
}
