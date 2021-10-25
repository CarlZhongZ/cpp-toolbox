#include <iostream>

#include "FixedPoint/FP32.h"
#include "FixedPoint/FP64.h"

using namespace std;

int main() {
	cout << "test main begin" << endl;

	common::FP32 v(0);
	auto r = v + 10;
	cout << r.raw() << endl;
	return 0;
}
