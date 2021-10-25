#pragma once
#include <bitset>
#include <cstdint>
#include <cmath>
#include <type_traits>

namespace common {
	template<int N = 10, int IntBits = 22>
	class FP32 {
		int32_t rawValue = 0;

	public:
		int32_t raw() {
			return rawValue;
		}

		template <typename T, typename = typename std::enable_if<std::is_integral<T>::value, T>::type >
		FP32 operator =(T v) {
			rawValue = (T)v << N;
			return *this;
		}

		FP32() :rawValue(0) {
		}

		FP32(int32_t v):rawValue(v){
		}

		double toNumber() {
			return rawValue / (double)(1 << N);
		}

		template <typename T, typename = typename std::enable_if<std::is_integral<T>::value, T>::type >
		FP32 operator + (T v) {
			return rawValue + ((T)v << N);
		}

		FP32 operator + (FP32 p) {
			return rawValue + p.rawValue;
		}

		template <typename T, typename = typename std::enable_if<std::is_integral<T>::value, T>::type >
		FP32 operator - (T v) {
			return rawValue - ((T)v << N);
		}

		FP32 operator - (FP32 p) {
			return rawValue - p.rawValue;
		}

		template <typename T, typename = typename std::enable_if<std::is_integral<T>::value, T>::type >
		FP32 operator * (T v) {
			return ((int64_t)rawValue * ((T)v << N)) >> N;
		}

		FP32 operator * (FP32 p) {
			return ((int64_t)rawValue * p.rawValue) >> N;
		}

		template <typename T, typename = typename std::enable_if<std::is_integral<T>::value, T>::type >
		FP32 operator / (T v) {
			return ((int64_t)rawValue << N) / ((T)v << N);
		}

		FP32 operator / (FP32 p) {
			return ((int64_t)rawValue << N) / p.rawValue;
		}

		// 整数平方根算法
		FP32 sqrt() {
			unsigned long temp = 0;
			unsigned v_bit = 15;
			unsigned n = 0;
			unsigned b = 0x8000;

			uint32_t x = (uint32_t)rawValue << N;
			if (x <= 1)
				return x;

			do {
				temp = ((n << 1) + b) << (v_bit--);
				if (x >= temp)
				{
					n += b;
					x -= temp;
				}
			} while (b >>= 1);

			return n;
		}
	};
}
