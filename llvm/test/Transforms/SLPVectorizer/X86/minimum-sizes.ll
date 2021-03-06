; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -slp-threshold=-6 -slp-vectorizer -instcombine < %s | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; These tests ensure that we do not regress due to PR31243. Note that we set
; the SLP threshold to force vectorization even when not profitable.

; When computing minimum sizes, if we can prove the sign bit is zero, we can
; zero-extend the roots back to their original sizes.
;
define i8 @PR31243_zext(i8 %v0, i8 %v1, i8 %v2, i8 %v3, i8* %ptr) {
; CHECK-LABEL: @PR31243_zext(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = insertelement <2 x i8> undef, i8 [[V0:%.*]], i32 0
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <2 x i8> [[TMP0]], i8 [[V1:%.*]], i32 1
; CHECK-NEXT:    [[TMP2:%.*]] = or <2 x i8> [[TMP1]], <i8 1, i8 1>
; CHECK-NEXT:    [[TMP3:%.*]] = extractelement <2 x i8> [[TMP2]], i32 0
; CHECK-NEXT:    [[TMP4:%.*]] = zext i8 [[TMP3]] to i64
; CHECK-NEXT:    [[TMPE4:%.*]] = getelementptr inbounds i8, i8* [[PTR:%.*]], i64 [[TMP4]]
; CHECK-NEXT:    [[TMP5:%.*]] = extractelement <2 x i8> [[TMP2]], i32 1
; CHECK-NEXT:    [[TMP6:%.*]] = zext i8 [[TMP5]] to i64
; CHECK-NEXT:    [[TMP5:%.*]] = getelementptr inbounds i8, i8* [[PTR]], i64 [[TMP6]]
; CHECK-NEXT:    [[TMP6:%.*]] = load i8, i8* [[TMPE4]], align 1
; CHECK-NEXT:    [[TMP7:%.*]] = load i8, i8* [[TMP5]], align 1
; CHECK-NEXT:    [[TMP8:%.*]] = add i8 [[TMP6]], [[TMP7]]
; CHECK-NEXT:    ret i8 [[TMP8]]
;
entry:
  %tmp0 = zext i8 %v0 to i32
  %tmp1 = zext i8 %v1 to i32
  %tmp2 = or i32 %tmp0, 1
  %tmp3 = or i32 %tmp1, 1
  %tmp4 = getelementptr inbounds i8, i8* %ptr, i32 %tmp2
  %tmp5 = getelementptr inbounds i8, i8* %ptr, i32 %tmp3
  %tmp6 = load i8, i8* %tmp4
  %tmp7 = load i8, i8* %tmp5
  %tmp8 = add i8 %tmp6, %tmp7
  ret i8 %tmp8
}

; When computing minimum sizes, if we cannot prove the sign bit is zero, we
; have to include one extra bit for signedness since we will sign-extend the
; roots.
;
; FIXME: This test is suboptimal since the compuation can be performed in i8.
;        In general, we need to add an extra bit to the maximum bit width only
;        if we can't prove that the upper bit of the original type is equal to
;        the upper bit of the proposed smaller type. If these two bits are the
;        same (either zero or one) we know that sign-extending from the smaller
;        type will result in the same value. Since we don't yet perform this
;        optimization, we make the proposed smaller type (i8) larger (i16) to
;        ensure correctness.
;
define i8 @PR31243_sext(i8 %v0, i8 %v1, i8 %v2, i8 %v3, i8* %ptr) {
; CHECK-LABEL: @PR31243_sext(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = insertelement <2 x i8> undef, i8 [[V0:%.*]], i32 0
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <2 x i8> [[TMP0]], i8 [[V1:%.*]], i32 1
; CHECK-NEXT:    [[TMP2:%.*]] = or <2 x i8> [[TMP1]], <i8 1, i8 1>
; CHECK-NEXT:    [[TMP3:%.*]] = sext <2 x i8> [[TMP2]] to <2 x i16>
; CHECK-NEXT:    [[TMP4:%.*]] = extractelement <2 x i16> [[TMP3]], i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = sext i16 [[TMP4]] to i64
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds i8, i8* [[PTR:%.*]], i64 [[TMP5]]
; CHECK-NEXT:    [[TMP6:%.*]] = extractelement <2 x i16> [[TMP3]], i32 1
; CHECK-NEXT:    [[TMP7:%.*]] = sext i16 [[TMP6]] to i64
; CHECK-NEXT:    [[TMP5:%.*]] = getelementptr inbounds i8, i8* [[PTR]], i64 [[TMP7]]
; CHECK-NEXT:    [[TMP6:%.*]] = load i8, i8* [[TMP4]], align 1
; CHECK-NEXT:    [[TMP7:%.*]] = load i8, i8* [[TMP5]], align 1
; CHECK-NEXT:    [[TMP8:%.*]] = add i8 [[TMP6]], [[TMP7]]
; CHECK-NEXT:    ret i8 [[TMP8]]
;
entry:
  %tmp0 = sext i8 %v0 to i32
  %tmp1 = sext i8 %v1 to i32
  %tmp2 = or i32 %tmp0, 1
  %tmp3 = or i32 %tmp1, 1
  %tmp4 = getelementptr inbounds i8, i8* %ptr, i32 %tmp2
  %tmp5 = getelementptr inbounds i8, i8* %ptr, i32 %tmp3
  %tmp6 = load i8, i8* %tmp4
  %tmp7 = load i8, i8* %tmp5
  %tmp8 = add i8 %tmp6, %tmp7
  ret i8 %tmp8
}
