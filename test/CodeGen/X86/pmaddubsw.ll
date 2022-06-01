; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+ssse3 | FileCheck %s --check-prefix=SSE
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefixes=AVX,AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefixes=AVX,AVX256,AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f | FileCheck %s --check-prefixes=AVX,AVX256,AVX512,AVX512F
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512bw | FileCheck %s --check-prefixes=AVX,AVX256,AVX512,AVX512BW

; NOTE: We're testing with loads because ABI lowering creates a concat_vectors that extract_vector_elt creation can see through.
; This would require the combine to recreate the concat_vectors.
define <8 x i16> @pmaddubsw_128(<16 x i8>* %Aptr, <16 x i8>* %Bptr) {
; SSE-LABEL: pmaddubsw_128:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa (%rsi), %xmm0
; SSE-NEXT:    pmaddubsw (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: pmaddubsw_128:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovdqa (%rsi), %xmm0
; AVX-NEXT:    vpmaddubsw (%rdi), %xmm0, %xmm0
; AVX-NEXT:    retq
  %A = load <16 x i8>, <16 x i8>* %Aptr
  %B = load <16 x i8>, <16 x i8>* %Bptr
  %A_even = shufflevector <16 x i8> %A, <16 x i8> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %A_odd = shufflevector <16 x i8> %A, <16 x i8> undef, <8 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15>
  %B_even = shufflevector <16 x i8> %B, <16 x i8> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %B_odd = shufflevector <16 x i8> %B, <16 x i8> undef, <8 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15>
  %A_even_ext = sext <8 x i8> %A_even to <8 x i32>
  %B_even_ext = zext <8 x i8> %B_even to <8 x i32>
  %A_odd_ext = sext <8 x i8> %A_odd to <8 x i32>
  %B_odd_ext = zext <8 x i8> %B_odd to <8 x i32>
  %even_mul = mul <8 x i32> %A_even_ext, %B_even_ext
  %odd_mul = mul <8 x i32> %A_odd_ext, %B_odd_ext
  %add = add <8 x i32> %even_mul, %odd_mul
  %cmp_max = icmp sgt <8 x i32> %add, <i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768>
  %max = select <8 x i1> %cmp_max, <8 x i32> %add, <8 x i32> <i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768>
  %cmp_min = icmp slt <8 x i32> %max, <i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767>
  %min = select <8 x i1> %cmp_min, <8 x i32> %max, <8 x i32> <i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767>
  %trunc = trunc <8 x i32> %min to <8 x i16>
  ret <8 x i16> %trunc
}

define <16 x i16> @pmaddubsw_256(<32 x i8>* %Aptr, <32 x i8>* %Bptr) {
; SSE-LABEL: pmaddubsw_256:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa (%rsi), %xmm0
; SSE-NEXT:    movdqa 16(%rsi), %xmm1
; SSE-NEXT:    pmaddubsw (%rdi), %xmm0
; SSE-NEXT:    pmaddubsw 16(%rdi), %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: pmaddubsw_256:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovdqa (%rsi), %xmm0
; AVX1-NEXT:    vmovdqa 16(%rsi), %xmm1
; AVX1-NEXT:    vpmaddubsw 16(%rdi), %xmm1, %xmm1
; AVX1-NEXT:    vpmaddubsw (%rdi), %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX256-LABEL: pmaddubsw_256:
; AVX256:       # %bb.0:
; AVX256-NEXT:    vmovdqa (%rsi), %ymm0
; AVX256-NEXT:    vpmaddubsw (%rdi), %ymm0, %ymm0
; AVX256-NEXT:    retq
  %A = load <32 x i8>, <32 x i8>* %Aptr
  %B = load <32 x i8>, <32 x i8>* %Bptr
  %A_even = shufflevector <32 x i8> %A, <32 x i8> undef, <16 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14, i32 16, i32 18, i32 20, i32 22, i32 24, i32 26, i32 28, i32 30>
  %A_odd = shufflevector <32 x i8> %A, <32 x i8> undef, <16 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15, i32 17, i32 19, i32 21, i32 23, i32 25, i32 27, i32 29, i32 31>
  %B_even = shufflevector <32 x i8> %B, <32 x i8> undef, <16 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14, i32 16, i32 18, i32 20, i32 22, i32 24, i32 26, i32 28, i32 30>
  %B_odd = shufflevector <32 x i8> %B, <32 x i8> undef, <16 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15, i32 17, i32 19, i32 21, i32 23, i32 25, i32 27, i32 29, i32 31>
  %A_even_ext = sext <16 x i8> %A_even to <16 x i32>
  %B_even_ext = zext <16 x i8> %B_even to <16 x i32>
  %A_odd_ext = sext <16 x i8> %A_odd to <16 x i32>
  %B_odd_ext = zext <16 x i8> %B_odd to <16 x i32>
  %even_mul = mul <16 x i32> %A_even_ext, %B_even_ext
  %odd_mul = mul <16 x i32> %A_odd_ext, %B_odd_ext
  %add = add <16 x i32> %even_mul, %odd_mul
  %cmp_max = icmp sgt <16 x i32> %add, <i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768>
  %max = select <16 x i1> %cmp_max, <16 x i32> %add, <16 x i32> <i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768>
  %cmp_min = icmp slt <16 x i32> %max, <i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767>
  %min = select <16 x i1> %cmp_min, <16 x i32> %max, <16 x i32> <i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767>
  %trunc = trunc <16 x i32> %min to <16 x i16>
  ret <16 x i16> %trunc
}

define <64 x i16> @pmaddubsw_512(<128 x i8>* %Aptr, <128 x i8>* %Bptr) {
; SSE-LABEL: pmaddubsw_512:
; SSE:       # %bb.0:
; SSE-NEXT:    movq %rdi, %rax
; SSE-NEXT:    movdqa (%rdx), %xmm0
; SSE-NEXT:    movdqa 16(%rdx), %xmm1
; SSE-NEXT:    movdqa 32(%rdx), %xmm2
; SSE-NEXT:    movdqa 48(%rdx), %xmm3
; SSE-NEXT:    pmaddubsw (%rsi), %xmm0
; SSE-NEXT:    pmaddubsw 16(%rsi), %xmm1
; SSE-NEXT:    pmaddubsw 32(%rsi), %xmm2
; SSE-NEXT:    pmaddubsw 48(%rsi), %xmm3
; SSE-NEXT:    movdqa 64(%rdx), %xmm4
; SSE-NEXT:    pmaddubsw 64(%rsi), %xmm4
; SSE-NEXT:    movdqa 80(%rdx), %xmm5
; SSE-NEXT:    pmaddubsw 80(%rsi), %xmm5
; SSE-NEXT:    movdqa 96(%rdx), %xmm6
; SSE-NEXT:    pmaddubsw 96(%rsi), %xmm6
; SSE-NEXT:    movdqa 112(%rdx), %xmm7
; SSE-NEXT:    pmaddubsw 112(%rsi), %xmm7
; SSE-NEXT:    movdqa %xmm7, 112(%rdi)
; SSE-NEXT:    movdqa %xmm6, 96(%rdi)
; SSE-NEXT:    movdqa %xmm5, 80(%rdi)
; SSE-NEXT:    movdqa %xmm4, 64(%rdi)
; SSE-NEXT:    movdqa %xmm3, 48(%rdi)
; SSE-NEXT:    movdqa %xmm2, 32(%rdi)
; SSE-NEXT:    movdqa %xmm1, 16(%rdi)
; SSE-NEXT:    movdqa %xmm0, (%rdi)
; SSE-NEXT:    retq
;
; AVX1-LABEL: pmaddubsw_512:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovdqa (%rsi), %xmm0
; AVX1-NEXT:    vmovdqa 16(%rsi), %xmm1
; AVX1-NEXT:    vmovdqa 32(%rsi), %xmm2
; AVX1-NEXT:    vmovdqa 48(%rsi), %xmm3
; AVX1-NEXT:    vpmaddubsw 16(%rdi), %xmm1, %xmm1
; AVX1-NEXT:    vpmaddubsw (%rdi), %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    vpmaddubsw 48(%rdi), %xmm3, %xmm1
; AVX1-NEXT:    vpmaddubsw 32(%rdi), %xmm2, %xmm2
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm2, %ymm1
; AVX1-NEXT:    vmovdqa 80(%rsi), %xmm2
; AVX1-NEXT:    vpmaddubsw 80(%rdi), %xmm2, %xmm2
; AVX1-NEXT:    vmovdqa 64(%rsi), %xmm3
; AVX1-NEXT:    vpmaddubsw 64(%rdi), %xmm3, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vmovdqa 112(%rsi), %xmm3
; AVX1-NEXT:    vpmaddubsw 112(%rdi), %xmm3, %xmm3
; AVX1-NEXT:    vmovdqa 96(%rsi), %xmm4
; AVX1-NEXT:    vpmaddubsw 96(%rdi), %xmm4, %xmm4
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm4, %ymm3
; AVX1-NEXT:    retq
;
; AVX2-LABEL: pmaddubsw_512:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovdqa (%rsi), %ymm0
; AVX2-NEXT:    vmovdqa 32(%rsi), %ymm1
; AVX2-NEXT:    vmovdqa 64(%rsi), %ymm2
; AVX2-NEXT:    vmovdqa 96(%rsi), %ymm3
; AVX2-NEXT:    vpmaddubsw (%rdi), %ymm0, %ymm0
; AVX2-NEXT:    vpmaddubsw 32(%rdi), %ymm1, %ymm1
; AVX2-NEXT:    vpmaddubsw 64(%rdi), %ymm2, %ymm2
; AVX2-NEXT:    vpmaddubsw 96(%rdi), %ymm3, %ymm3
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: pmaddubsw_512:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vmovdqa (%rsi), %ymm0
; AVX512F-NEXT:    vmovdqa 32(%rsi), %ymm1
; AVX512F-NEXT:    vmovdqa 64(%rsi), %ymm2
; AVX512F-NEXT:    vmovdqa 96(%rsi), %ymm3
; AVX512F-NEXT:    vpmaddubsw (%rdi), %ymm0, %ymm0
; AVX512F-NEXT:    vpmaddubsw 32(%rdi), %ymm1, %ymm1
; AVX512F-NEXT:    vpmaddubsw 64(%rdi), %ymm2, %ymm2
; AVX512F-NEXT:    vpmaddubsw 96(%rdi), %ymm3, %ymm3
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: pmaddubsw_512:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vmovdqa64 (%rsi), %zmm0
; AVX512BW-NEXT:    vmovdqa64 64(%rsi), %zmm1
; AVX512BW-NEXT:    vpmaddubsw (%rdi), %zmm0, %zmm0
; AVX512BW-NEXT:    vpmaddubsw 64(%rdi), %zmm1, %zmm1
; AVX512BW-NEXT:    retq
  %A = load <128 x i8>, <128 x i8>* %Aptr
  %B = load <128 x i8>, <128 x i8>* %Bptr
  %A_even = shufflevector <128 x i8> %A, <128 x i8> undef, <64 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14, i32 16, i32 18, i32 20, i32 22, i32 24, i32 26, i32 28, i32 30, i32 32, i32 34, i32 36, i32 38, i32 40, i32 42, i32 44, i32 46, i32 48, i32 50, i32 52, i32 54, i32 56, i32 58, i32 60, i32 62, i32 64, i32 66, i32 68, i32 70, i32 72, i32 74, i32 76, i32 78, i32 80, i32 82, i32 84, i32 86, i32 88, i32 90, i32 92, i32 94, i32 96, i32 98, i32 100, i32 102, i32 104, i32 106, i32 108, i32 110, i32 112, i32 114, i32 116, i32 118, i32 120, i32 122, i32 124, i32 126>
  %A_odd = shufflevector <128 x i8> %A, <128 x i8> undef, <64 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15, i32 17, i32 19, i32 21, i32 23, i32 25, i32 27, i32 29, i32 31, i32 33, i32 35, i32 37, i32 39, i32 41, i32 43, i32 45, i32 47, i32 49, i32 51, i32 53, i32 55, i32 57, i32 59, i32 61, i32 63, i32 65, i32 67, i32 69, i32 71, i32 73, i32 75, i32 77, i32 79, i32 81, i32 83, i32 85, i32 87, i32 89, i32 91, i32 93, i32 95, i32 97, i32 99, i32 101, i32 103, i32 105, i32 107, i32 109, i32 111, i32 113, i32 115, i32 117, i32 119, i32 121, i32 123, i32 125, i32 127>
  %B_even = shufflevector <128 x i8> %B, <128 x i8> undef, <64 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14, i32 16, i32 18, i32 20, i32 22, i32 24, i32 26, i32 28, i32 30, i32 32, i32 34, i32 36, i32 38, i32 40, i32 42, i32 44, i32 46, i32 48, i32 50, i32 52, i32 54, i32 56, i32 58, i32 60, i32 62, i32 64, i32 66, i32 68, i32 70, i32 72, i32 74, i32 76, i32 78, i32 80, i32 82, i32 84, i32 86, i32 88, i32 90, i32 92, i32 94, i32 96, i32 98, i32 100, i32 102, i32 104, i32 106, i32 108, i32 110, i32 112, i32 114, i32 116, i32 118, i32 120, i32 122, i32 124, i32 126>
  %B_odd = shufflevector <128 x i8> %B, <128 x i8> undef, <64 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15, i32 17, i32 19, i32 21, i32 23, i32 25, i32 27, i32 29, i32 31, i32 33, i32 35, i32 37, i32 39, i32 41, i32 43, i32 45, i32 47, i32 49, i32 51, i32 53, i32 55, i32 57, i32 59, i32 61, i32 63, i32 65, i32 67, i32 69, i32 71, i32 73, i32 75, i32 77, i32 79, i32 81, i32 83, i32 85, i32 87, i32 89, i32 91, i32 93, i32 95, i32 97, i32 99, i32 101, i32 103, i32 105, i32 107, i32 109, i32 111, i32 113, i32 115, i32 117, i32 119, i32 121, i32 123, i32 125, i32 127>
  %A_even_ext = sext <64 x i8> %A_even to <64 x i32>
  %B_even_ext = zext <64 x i8> %B_even to <64 x i32>
  %A_odd_ext = sext <64 x i8> %A_odd to <64 x i32>
  %B_odd_ext = zext <64 x i8> %B_odd to <64 x i32>
  %even_mul = mul <64 x i32> %A_even_ext, %B_even_ext
  %odd_mul = mul <64 x i32> %A_odd_ext, %B_odd_ext
  %add = add <64 x i32> %even_mul, %odd_mul
  %cmp_max = icmp sgt <64 x i32> %add, <i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768>
  %max = select <64 x i1> %cmp_max, <64 x i32> %add, <64 x i32> <i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768>
  %cmp_min = icmp slt <64 x i32> %max, <i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767>
  %min = select <64 x i1> %cmp_min, <64 x i32> %max, <64 x i32> <i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767>
  %trunc = trunc <64 x i32> %min to <64 x i16>
  ret <64 x i16> %trunc
}

define <8 x i16> @pmaddubsw_swapped_indices(<16 x i8>* %Aptr, <16 x i8>* %Bptr) {
; SSE-LABEL: pmaddubsw_swapped_indices:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa (%rsi), %xmm0
; SSE-NEXT:    pmaddubsw (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: pmaddubsw_swapped_indices:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovdqa (%rsi), %xmm0
; AVX-NEXT:    vpmaddubsw (%rdi), %xmm0, %xmm0
; AVX-NEXT:    retq
  %A = load <16 x i8>, <16 x i8>* %Aptr
  %B = load <16 x i8>, <16 x i8>* %Bptr
  %A_even = shufflevector <16 x i8> %A, <16 x i8> undef, <8 x i32> <i32 1, i32 2, i32 5, i32 6, i32 9, i32 10, i32 13, i32 14> ;indices aren't all even
  %A_odd = shufflevector <16 x i8> %A, <16 x i8> undef, <8 x i32> <i32 0, i32 3, i32 4, i32 7, i32 8, i32 11, i32 12, i32 15> ;indices aren't all odd
  %B_even = shufflevector <16 x i8> %B, <16 x i8> undef, <8 x i32> <i32 1, i32 2, i32 5, i32 6, i32 9, i32 10, i32 13, i32 14> ;same indices as A
  %B_odd = shufflevector <16 x i8> %B, <16 x i8> undef, <8 x i32> <i32 0, i32 3, i32 4, i32 7, i32 8, i32 11, i32 12, i32 15> ;same indices as A
  %A_even_ext = sext <8 x i8> %A_even to <8 x i32>
  %B_even_ext = zext <8 x i8> %B_even to <8 x i32>
  %A_odd_ext = sext <8 x i8> %A_odd to <8 x i32>
  %B_odd_ext = zext <8 x i8> %B_odd to <8 x i32>
  %even_mul = mul <8 x i32> %A_even_ext, %B_even_ext
  %odd_mul = mul <8 x i32> %A_odd_ext, %B_odd_ext
  %add = add <8 x i32> %even_mul, %odd_mul
  %cmp_max = icmp sgt <8 x i32> %add, <i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768>
  %max = select <8 x i1> %cmp_max, <8 x i32> %add, <8 x i32> <i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768>
  %cmp_min = icmp slt <8 x i32> %max, <i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767>
  %min = select <8 x i1> %cmp_min, <8 x i32> %max, <8 x i32> <i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767>
  %trunc = trunc <8 x i32> %min to <8 x i16>
  ret <8 x i16> %trunc
}

define <8 x i16> @pmaddubsw_swapped_extend(<16 x i8>* %Aptr, <16 x i8>* %Bptr) {
; SSE-LABEL: pmaddubsw_swapped_extend:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa (%rdi), %xmm0
; SSE-NEXT:    pmaddubsw (%rsi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: pmaddubsw_swapped_extend:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovdqa (%rdi), %xmm0
; AVX-NEXT:    vpmaddubsw (%rsi), %xmm0, %xmm0
; AVX-NEXT:    retq
  %A = load <16 x i8>, <16 x i8>* %Aptr
  %B = load <16 x i8>, <16 x i8>* %Bptr
  %A_even = shufflevector <16 x i8> %A, <16 x i8> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %A_odd = shufflevector <16 x i8> %A, <16 x i8> undef, <8 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15>
  %B_even = shufflevector <16 x i8> %B, <16 x i8> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %B_odd = shufflevector <16 x i8> %B, <16 x i8> undef, <8 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15>
  %A_even_ext = zext <8 x i8> %A_even to <8 x i32>
  %B_even_ext = sext <8 x i8> %B_even to <8 x i32>
  %A_odd_ext = zext <8 x i8> %A_odd to <8 x i32>
  %B_odd_ext = sext <8 x i8> %B_odd to <8 x i32>
  %even_mul = mul <8 x i32> %A_even_ext, %B_even_ext
  %odd_mul = mul <8 x i32> %A_odd_ext, %B_odd_ext
  %add = add <8 x i32> %even_mul, %odd_mul
  %cmp_max = icmp sgt <8 x i32> %add, <i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768>
  %max = select <8 x i1> %cmp_max, <8 x i32> %add, <8 x i32> <i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768>
  %cmp_min = icmp slt <8 x i32> %max, <i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767>
  %min = select <8 x i1> %cmp_min, <8 x i32> %max, <8 x i32> <i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767>
  %trunc = trunc <8 x i32> %min to <8 x i16>
  ret <8 x i16> %trunc
}

define <8 x i16> @pmaddubsw_commuted_mul(<16 x i8>* %Aptr, <16 x i8>* %Bptr) {
; SSE-LABEL: pmaddubsw_commuted_mul:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa (%rsi), %xmm0
; SSE-NEXT:    pmaddubsw (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: pmaddubsw_commuted_mul:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovdqa (%rsi), %xmm0
; AVX-NEXT:    vpmaddubsw (%rdi), %xmm0, %xmm0
; AVX-NEXT:    retq
  %A = load <16 x i8>, <16 x i8>* %Aptr
  %B = load <16 x i8>, <16 x i8>* %Bptr
  %A_even = shufflevector <16 x i8> %A, <16 x i8> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %A_odd = shufflevector <16 x i8> %A, <16 x i8> undef, <8 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15>
  %B_even = shufflevector <16 x i8> %B, <16 x i8> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %B_odd = shufflevector <16 x i8> %B, <16 x i8> undef, <8 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15>
  %A_even_ext = sext <8 x i8> %A_even to <8 x i32>
  %B_even_ext = zext <8 x i8> %B_even to <8 x i32>
  %A_odd_ext = sext <8 x i8> %A_odd to <8 x i32>
  %B_odd_ext = zext <8 x i8> %B_odd to <8 x i32>
  %even_mul = mul <8 x i32> %B_even_ext, %A_even_ext
  %odd_mul = mul <8 x i32> %A_odd_ext, %B_odd_ext
  %add = add <8 x i32> %even_mul, %odd_mul
  %cmp_max = icmp sgt <8 x i32> %add, <i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768>
  %max = select <8 x i1> %cmp_max, <8 x i32> %add, <8 x i32> <i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768>
  %cmp_min = icmp slt <8 x i32> %max, <i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767>
  %min = select <8 x i1> %cmp_min, <8 x i32> %max, <8 x i32> <i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767>
  %trunc = trunc <8 x i32> %min to <8 x i16>
  ret <8 x i16> %trunc
}

define <8 x i16> @pmaddubsw_bad_extend(<16 x i8>* %Aptr, <16 x i8>* %Bptr) {
; SSE-LABEL: pmaddubsw_bad_extend:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa (%rdi), %xmm1
; SSE-NEXT:    movdqa (%rsi), %xmm0
; SSE-NEXT:    movdqa {{.*#+}} xmm2 = [255,0,255,0,255,0,255,0,255,0,255,0,255,0,255,0]
; SSE-NEXT:    pand %xmm0, %xmm2
; SSE-NEXT:    movdqa %xmm1, %xmm3
; SSE-NEXT:    psllw $8, %xmm3
; SSE-NEXT:    psraw $8, %xmm3
; SSE-NEXT:    movdqa %xmm3, %xmm4
; SSE-NEXT:    pmulhw %xmm2, %xmm4
; SSE-NEXT:    pmullw %xmm2, %xmm3
; SSE-NEXT:    movdqa %xmm3, %xmm2
; SSE-NEXT:    punpcklwd {{.*#+}} xmm2 = xmm2[0],xmm4[0],xmm2[1],xmm4[1],xmm2[2],xmm4[2],xmm2[3],xmm4[3]
; SSE-NEXT:    punpckhwd {{.*#+}} xmm3 = xmm3[4],xmm4[4],xmm3[5],xmm4[5],xmm3[6],xmm4[6],xmm3[7],xmm4[7]
; SSE-NEXT:    psraw $8, %xmm0
; SSE-NEXT:    psrlw $8, %xmm1
; SSE-NEXT:    movdqa %xmm1, %xmm4
; SSE-NEXT:    pmulhw %xmm0, %xmm4
; SSE-NEXT:    pmullw %xmm0, %xmm1
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm4[0],xmm0[1],xmm4[1],xmm0[2],xmm4[2],xmm0[3],xmm4[3]
; SSE-NEXT:    paddd %xmm2, %xmm0
; SSE-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm4[4],xmm1[5],xmm4[5],xmm1[6],xmm4[6],xmm1[7],xmm4[7]
; SSE-NEXT:    paddd %xmm3, %xmm1
; SSE-NEXT:    packssdw %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX1-LABEL: pmaddubsw_bad_extend:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovdqa (%rdi), %xmm0
; AVX1-NEXT:    vmovdqa (%rsi), %xmm1
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = <0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u>
; AVX1-NEXT:    vpshufb %xmm2, %xmm0, %xmm3
; AVX1-NEXT:    vpmovsxbd %xmm3, %xmm4
; AVX1-NEXT:    vpshufd {{.*#+}} xmm3 = xmm3[1,1,2,3]
; AVX1-NEXT:    vpmovsxbd %xmm3, %xmm3
; AVX1-NEXT:    vpshufb %xmm2, %xmm1, %xmm2
; AVX1-NEXT:    vpmovzxbd {{.*#+}} xmm5 = xmm2[0],zero,zero,zero,xmm2[1],zero,zero,zero,xmm2[2],zero,zero,zero,xmm2[3],zero,zero,zero
; AVX1-NEXT:    vpmulld %xmm5, %xmm4, %xmm4
; AVX1-NEXT:    vpshufd {{.*#+}} xmm2 = xmm2[1,1,2,3]
; AVX1-NEXT:    vpmovzxbd {{.*#+}} xmm2 = xmm2[0],zero,zero,zero,xmm2[1],zero,zero,zero,xmm2[2],zero,zero,zero,xmm2[3],zero,zero,zero
; AVX1-NEXT:    vpmulld %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm3 = <1,3,5,7,9,11,13,15,u,u,u,u,u,u,u,u>
; AVX1-NEXT:    vpshufb %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpmovzxbd {{.*#+}} xmm5 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[1,1,2,3]
; AVX1-NEXT:    vpmovzxbd {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; AVX1-NEXT:    vpshufb %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vpmovsxbd %xmm1, %xmm3
; AVX1-NEXT:    vpmulld %xmm3, %xmm5, %xmm3
; AVX1-NEXT:    vpaddd %xmm3, %xmm4, %xmm3
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[1,1,2,3]
; AVX1-NEXT:    vpmovsxbd %xmm1, %xmm1
; AVX1-NEXT:    vpmulld %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpaddd %xmm0, %xmm2, %xmm0
; AVX1-NEXT:    vpackssdw %xmm0, %xmm3, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: pmaddubsw_bad_extend:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovdqa (%rdi), %xmm0
; AVX2-NEXT:    vmovdqa (%rsi), %xmm1
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm2 = <0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u>
; AVX2-NEXT:    vpshufb %xmm2, %xmm0, %xmm3
; AVX2-NEXT:    vpmovsxbd %xmm3, %ymm3
; AVX2-NEXT:    vpshufb %xmm2, %xmm1, %xmm2
; AVX2-NEXT:    vpmovzxbd {{.*#+}} ymm2 = xmm2[0],zero,zero,zero,xmm2[1],zero,zero,zero,xmm2[2],zero,zero,zero,xmm2[3],zero,zero,zero,xmm2[4],zero,zero,zero,xmm2[5],zero,zero,zero,xmm2[6],zero,zero,zero,xmm2[7],zero,zero,zero
; AVX2-NEXT:    vpmulld %ymm2, %ymm3, %ymm2
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm3 = <1,3,5,7,9,11,13,15,u,u,u,u,u,u,u,u>
; AVX2-NEXT:    vpshufb %xmm3, %xmm0, %xmm0
; AVX2-NEXT:    vpmovzxbd {{.*#+}} ymm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero,xmm0[4],zero,zero,zero,xmm0[5],zero,zero,zero,xmm0[6],zero,zero,zero,xmm0[7],zero,zero,zero
; AVX2-NEXT:    vpshufb %xmm3, %xmm1, %xmm1
; AVX2-NEXT:    vpmovsxbd %xmm1, %ymm1
; AVX2-NEXT:    vpmulld %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpaddd %ymm0, %ymm2, %ymm0
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpackssdw %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: pmaddubsw_bad_extend:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512-NEXT:    vmovdqa (%rsi), %xmm1
; AVX512-NEXT:    vmovdqa {{.*#+}} xmm2 = <0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u>
; AVX512-NEXT:    vpshufb %xmm2, %xmm0, %xmm3
; AVX512-NEXT:    vpmovsxbd %xmm3, %ymm3
; AVX512-NEXT:    vpshufb %xmm2, %xmm1, %xmm2
; AVX512-NEXT:    vpmovzxbd {{.*#+}} ymm2 = xmm2[0],zero,zero,zero,xmm2[1],zero,zero,zero,xmm2[2],zero,zero,zero,xmm2[3],zero,zero,zero,xmm2[4],zero,zero,zero,xmm2[5],zero,zero,zero,xmm2[6],zero,zero,zero,xmm2[7],zero,zero,zero
; AVX512-NEXT:    vpmulld %ymm2, %ymm3, %ymm2
; AVX512-NEXT:    vmovdqa {{.*#+}} xmm3 = <1,3,5,7,9,11,13,15,u,u,u,u,u,u,u,u>
; AVX512-NEXT:    vpshufb %xmm3, %xmm0, %xmm0
; AVX512-NEXT:    vpmovzxbd {{.*#+}} ymm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero,xmm0[4],zero,zero,zero,xmm0[5],zero,zero,zero,xmm0[6],zero,zero,zero,xmm0[7],zero,zero,zero
; AVX512-NEXT:    vpshufb %xmm3, %xmm1, %xmm1
; AVX512-NEXT:    vpmovsxbd %xmm1, %ymm1
; AVX512-NEXT:    vpmulld %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpaddd %ymm0, %ymm2, %ymm0
; AVX512-NEXT:    vpbroadcastd {{.*#+}} ymm1 = [4294934528,4294934528,4294934528,4294934528,4294934528,4294934528,4294934528,4294934528]
; AVX512-NEXT:    vpmaxsd %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpbroadcastd {{.*#+}} ymm1 = [32767,32767,32767,32767,32767,32767,32767,32767]
; AVX512-NEXT:    vpminsd %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpmovdw %zmm0, %ymm0
; AVX512-NEXT:    # kill: def $xmm0 killed $xmm0 killed $ymm0
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %A = load <16 x i8>, <16 x i8>* %Aptr
  %B = load <16 x i8>, <16 x i8>* %Bptr
  %A_even = shufflevector <16 x i8> %A, <16 x i8> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %A_odd = shufflevector <16 x i8> %A, <16 x i8> undef, <8 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15>
  %B_even = shufflevector <16 x i8> %B, <16 x i8> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %B_odd = shufflevector <16 x i8> %B, <16 x i8> undef, <8 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15>
  %A_even_ext = sext <8 x i8> %A_even to <8 x i32>
  %B_even_ext = zext <8 x i8> %B_even to <8 x i32>
  %A_odd_ext = zext <8 x i8> %A_odd to <8 x i32>
  %B_odd_ext = sext <8 x i8> %B_odd to <8 x i32>
  %even_mul = mul <8 x i32> %A_even_ext, %B_even_ext
  %odd_mul = mul <8 x i32> %A_odd_ext, %B_odd_ext
  %add = add <8 x i32> %even_mul, %odd_mul
  %cmp_max = icmp sgt <8 x i32> %add, <i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768>
  %max = select <8 x i1> %cmp_max, <8 x i32> %add, <8 x i32> <i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768>
  %cmp_min = icmp slt <8 x i32> %max, <i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767>
  %min = select <8 x i1> %cmp_min, <8 x i32> %max, <8 x i32> <i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767>
  %trunc = trunc <8 x i32> %min to <8 x i16>
  ret <8 x i16> %trunc
}

define <8 x i16> @pmaddubsw_bad_indices(<16 x i8>* %Aptr, <16 x i8>* %Bptr) {
; SSE-LABEL: pmaddubsw_bad_indices:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa (%rdi), %xmm1
; SSE-NEXT:    movdqa (%rsi), %xmm0
; SSE-NEXT:    movdqa {{.*#+}} xmm2 = [255,0,255,0,255,0,255,0,255,0,255,0,255,0,255,0]
; SSE-NEXT:    pand %xmm0, %xmm2
; SSE-NEXT:    movdqa %xmm1, %xmm3
; SSE-NEXT:    pshufb {{.*#+}} xmm3 = xmm3[u,1,u,2,u,5,u,6,u,9,u,10,u,13,u,14]
; SSE-NEXT:    psraw $8, %xmm3
; SSE-NEXT:    movdqa %xmm3, %xmm4
; SSE-NEXT:    pmulhw %xmm2, %xmm4
; SSE-NEXT:    pmullw %xmm2, %xmm3
; SSE-NEXT:    movdqa %xmm3, %xmm2
; SSE-NEXT:    punpcklwd {{.*#+}} xmm2 = xmm2[0],xmm4[0],xmm2[1],xmm4[1],xmm2[2],xmm4[2],xmm2[3],xmm4[3]
; SSE-NEXT:    punpckhwd {{.*#+}} xmm3 = xmm3[4],xmm4[4],xmm3[5],xmm4[5],xmm3[6],xmm4[6],xmm3[7],xmm4[7]
; SSE-NEXT:    psrlw $8, %xmm0
; SSE-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[u,0,u,3,u,4,u,7,u,8,u,11,u,12,u,15]
; SSE-NEXT:    psraw $8, %xmm1
; SSE-NEXT:    movdqa %xmm1, %xmm4
; SSE-NEXT:    pmulhw %xmm0, %xmm4
; SSE-NEXT:    pmullw %xmm0, %xmm1
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm4[0],xmm0[1],xmm4[1],xmm0[2],xmm4[2],xmm0[3],xmm4[3]
; SSE-NEXT:    paddd %xmm2, %xmm0
; SSE-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm4[4],xmm1[5],xmm4[5],xmm1[6],xmm4[6],xmm1[7],xmm4[7]
; SSE-NEXT:    paddd %xmm3, %xmm1
; SSE-NEXT:    packssdw %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX1-LABEL: pmaddubsw_bad_indices:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovdqa (%rdi), %xmm0
; AVX1-NEXT:    vmovdqa (%rsi), %xmm1
; AVX1-NEXT:    vpshufb {{.*#+}} xmm2 = xmm0[1,2,5,6,9,10,13,14,u,u,u,u,u,u,u,u]
; AVX1-NEXT:    vpmovsxbd %xmm2, %xmm3
; AVX1-NEXT:    vpshufd {{.*#+}} xmm2 = xmm2[1,1,2,3]
; AVX1-NEXT:    vpmovsxbd %xmm2, %xmm2
; AVX1-NEXT:    vpshufb {{.*#+}} xmm4 = xmm1[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; AVX1-NEXT:    vpmovzxbd {{.*#+}} xmm5 = xmm4[0],zero,zero,zero,xmm4[1],zero,zero,zero,xmm4[2],zero,zero,zero,xmm4[3],zero,zero,zero
; AVX1-NEXT:    vpmulld %xmm5, %xmm3, %xmm3
; AVX1-NEXT:    vpshufd {{.*#+}} xmm4 = xmm4[1,1,2,3]
; AVX1-NEXT:    vpmovzxbd {{.*#+}} xmm4 = xmm4[0],zero,zero,zero,xmm4[1],zero,zero,zero,xmm4[2],zero,zero,zero,xmm4[3],zero,zero,zero
; AVX1-NEXT:    vpmulld %xmm4, %xmm2, %xmm2
; AVX1-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,3,4,7,8,11,12,15,u,u,u,u,u,u,u,u]
; AVX1-NEXT:    vpmovsxbd %xmm0, %xmm4
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[1,1,2,3]
; AVX1-NEXT:    vpmovsxbd %xmm0, %xmm0
; AVX1-NEXT:    vpshufb {{.*#+}} xmm1 = xmm1[1,3,5,7,9,11,13,15,u,u,u,u,u,u,u,u]
; AVX1-NEXT:    vpmovzxbd {{.*#+}} xmm5 = xmm1[0],zero,zero,zero,xmm1[1],zero,zero,zero,xmm1[2],zero,zero,zero,xmm1[3],zero,zero,zero
; AVX1-NEXT:    vpmulld %xmm5, %xmm4, %xmm4
; AVX1-NEXT:    vpaddd %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[1,1,2,3]
; AVX1-NEXT:    vpmovzxbd {{.*#+}} xmm1 = xmm1[0],zero,zero,zero,xmm1[1],zero,zero,zero,xmm1[2],zero,zero,zero,xmm1[3],zero,zero,zero
; AVX1-NEXT:    vpmulld %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpaddd %xmm0, %xmm2, %xmm0
; AVX1-NEXT:    vpackssdw %xmm0, %xmm3, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: pmaddubsw_bad_indices:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovdqa (%rdi), %xmm0
; AVX2-NEXT:    vmovdqa (%rsi), %xmm1
; AVX2-NEXT:    vpshufb {{.*#+}} xmm2 = xmm0[1,2,5,6,9,10,13,14,u,u,u,u,u,u,u,u]
; AVX2-NEXT:    vpmovsxbd %xmm2, %ymm2
; AVX2-NEXT:    vpshufb {{.*#+}} xmm3 = xmm1[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; AVX2-NEXT:    vpmovzxbd {{.*#+}} ymm3 = xmm3[0],zero,zero,zero,xmm3[1],zero,zero,zero,xmm3[2],zero,zero,zero,xmm3[3],zero,zero,zero,xmm3[4],zero,zero,zero,xmm3[5],zero,zero,zero,xmm3[6],zero,zero,zero,xmm3[7],zero,zero,zero
; AVX2-NEXT:    vpmulld %ymm3, %ymm2, %ymm2
; AVX2-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,3,4,7,8,11,12,15,u,u,u,u,u,u,u,u]
; AVX2-NEXT:    vpmovsxbd %xmm0, %ymm0
; AVX2-NEXT:    vpshufb {{.*#+}} xmm1 = xmm1[1,3,5,7,9,11,13,15,u,u,u,u,u,u,u,u]
; AVX2-NEXT:    vpmovzxbd {{.*#+}} ymm1 = xmm1[0],zero,zero,zero,xmm1[1],zero,zero,zero,xmm1[2],zero,zero,zero,xmm1[3],zero,zero,zero,xmm1[4],zero,zero,zero,xmm1[5],zero,zero,zero,xmm1[6],zero,zero,zero,xmm1[7],zero,zero,zero
; AVX2-NEXT:    vpmulld %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpaddd %ymm0, %ymm2, %ymm0
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpackssdw %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: pmaddubsw_bad_indices:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512-NEXT:    vmovdqa (%rsi), %xmm1
; AVX512-NEXT:    vpshufb {{.*#+}} xmm2 = xmm0[1,2,5,6,9,10,13,14,u,u,u,u,u,u,u,u]
; AVX512-NEXT:    vpmovsxbd %xmm2, %ymm2
; AVX512-NEXT:    vpshufb {{.*#+}} xmm3 = xmm1[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; AVX512-NEXT:    vpmovzxbd {{.*#+}} ymm3 = xmm3[0],zero,zero,zero,xmm3[1],zero,zero,zero,xmm3[2],zero,zero,zero,xmm3[3],zero,zero,zero,xmm3[4],zero,zero,zero,xmm3[5],zero,zero,zero,xmm3[6],zero,zero,zero,xmm3[7],zero,zero,zero
; AVX512-NEXT:    vpmulld %ymm3, %ymm2, %ymm2
; AVX512-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,3,4,7,8,11,12,15,u,u,u,u,u,u,u,u]
; AVX512-NEXT:    vpmovsxbd %xmm0, %ymm0
; AVX512-NEXT:    vpshufb {{.*#+}} xmm1 = xmm1[1,3,5,7,9,11,13,15,u,u,u,u,u,u,u,u]
; AVX512-NEXT:    vpmovzxbd {{.*#+}} ymm1 = xmm1[0],zero,zero,zero,xmm1[1],zero,zero,zero,xmm1[2],zero,zero,zero,xmm1[3],zero,zero,zero,xmm1[4],zero,zero,zero,xmm1[5],zero,zero,zero,xmm1[6],zero,zero,zero,xmm1[7],zero,zero,zero
; AVX512-NEXT:    vpmulld %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpaddd %ymm0, %ymm2, %ymm0
; AVX512-NEXT:    vpbroadcastd {{.*#+}} ymm1 = [4294934528,4294934528,4294934528,4294934528,4294934528,4294934528,4294934528,4294934528]
; AVX512-NEXT:    vpmaxsd %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpbroadcastd {{.*#+}} ymm1 = [32767,32767,32767,32767,32767,32767,32767,32767]
; AVX512-NEXT:    vpminsd %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpmovdw %zmm0, %ymm0
; AVX512-NEXT:    # kill: def $xmm0 killed $xmm0 killed $ymm0
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %A = load <16 x i8>, <16 x i8>* %Aptr
  %B = load <16 x i8>, <16 x i8>* %Bptr
  %A_even = shufflevector <16 x i8> %A, <16 x i8> undef, <8 x i32> <i32 1, i32 2, i32 5, i32 6, i32 9, i32 10, i32 13, i32 14> ;indices aren't all even
  %A_odd = shufflevector <16 x i8> %A, <16 x i8> undef, <8 x i32> <i32 0, i32 3, i32 4, i32 7, i32 8, i32 11, i32 12, i32 15> ;indices aren't all odd
  %B_even = shufflevector <16 x i8> %B, <16 x i8> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14> ;different than A
  %B_odd = shufflevector <16 x i8> %B, <16 x i8> undef, <8 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15> ;different than A
  %A_even_ext = sext <8 x i8> %A_even to <8 x i32>
  %B_even_ext = zext <8 x i8> %B_even to <8 x i32>
  %A_odd_ext = sext <8 x i8> %A_odd to <8 x i32>
  %B_odd_ext = zext <8 x i8> %B_odd to <8 x i32>
  %even_mul = mul <8 x i32> %A_even_ext, %B_even_ext
  %odd_mul = mul <8 x i32> %A_odd_ext, %B_odd_ext
  %add = add <8 x i32> %even_mul, %odd_mul
  %cmp_max = icmp sgt <8 x i32> %add, <i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768>
  %max = select <8 x i1> %cmp_max, <8 x i32> %add, <8 x i32> <i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768, i32 -32768>
  %cmp_min = icmp slt <8 x i32> %max, <i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767>
  %min = select <8 x i1> %cmp_min, <8 x i32> %max, <8 x i32> <i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767>
  %trunc = trunc <8 x i32> %min to <8 x i16>
  ret <8 x i16> %trunc
}
