#pragma once
#include <bitset>
#include <cstdint>
#include <cmath>
#include <type_traits>

namespace common {
	template<int N = 20, int IntBits = 44>
	class FP64 {
		int64_t rawValue = 0;
		static uint64_t floatBits;
		static uint64_t intBits;
	public:
		FP64 operator =(int64_t v) {
			rawValue = (int64_t)v << N;
			return *this;
		}

		FP64() :rawValue(0) {
		}

		FP64(int64_t v) :rawValue(v) {
		}

		double toNumber() {
			return rawValue / (double)(1 << N);
		}

		FP64 operator + (int64_t v) {
			return rawValue + (v << N);
		}

		FP64 operator + (FP64 p) {
			return rawValue + p.rawValue;
		}

		FP64 operator - (int64_t v) {
			return rawValue - (v << N);
		}

		FP64 operator - (FP64 p) {
			return rawValue - p.rawValue;
		}

		FP64 operator * (int64_t v) {
			uint64_t f = (rawValue & floatBits) * v;
			return (((rawValue >> N) * v + (f & intBits)) << N) + (f & floatBits);
		}

		FP64 operator * (FP64 p) {
			uint64_t f = (rawValue & floatBits) * p.rawValue;
			return (((rawValue >> N) * p.rawValue + (f & intBits)) << N) + (f & floatBits);
		}

		FP64 operator / (int64_t v) {
			return rawValue / v;
		}

		FP64 operator / (FP64 p) {
			if (p.rawValue & floatBits == 0) {
				return rawValue / (p.rawValue >> N);
			}
			else {
				// todo... 极有可能丢失高位精度
				return (rawValue << N) / p.rawValue >> N;
			}
		}

		FP64 sqrt() {
			uint64_t temp = 0;
			unsigned v_bit = 31;
			uint64_t n = 0;
			uint64_t b = 0x80000000;

			uint64_t x = (uint64_t)rawValue << N;
			if (x <= 1)
				return x;

			do {
				temp = ((n << 1) + b) << (v_bit--);
				if (x >= temp) {
					n += b;
					x -= temp;
				}
			} while (b >>= 1);

			return n;
		}
	};

}

