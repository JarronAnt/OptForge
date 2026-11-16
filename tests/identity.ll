
; CHECK-LABEL: define i32 @add_rhs(
; CHECK: entry:
; CHECK-NEXT: ret i32 %x
define i32 @add_rhs(i32 %x) {
entry:
  %a = add i32 %x, 0
  ret i32 %a
}

; CHECK-LABEL: define i32 @add_lhs(
; CHECK: entry:
; CHECK-NEXT: ret i32 %x
define i32 @add_lhs(i32 %x) {
entry:
  %a = add i32 0, %x
  ret i32 %a
}

; CHECK-LABEL: define i32 @sub_rhs(
; CHECK: entry:
; CHECK-NEXT: ret i32 %x
define i32 @sub_rhs(i32 %x) {
entry:
  %a = sub i32 %x, 0
  ret i32 %a
}

; CHECK-LABEL: define i32 @mul_lhs(
; CHECK: entry:
; CHECK-NEXT: ret i32 %x
define i32 @mul_lhs(i32 %x) {
entry:
  %a = mul i32 1, %x
  ret i32 %a
}

; CHECK-LABEL: define i32 @mul_rhs(
; CHECK: entry:
; CHECK-NEXT: ret i32 %x
define i32 @mul_rhs(i32 %x) {
entry:
  %a = mul i32 %x, 1
  ret i32 %a
}

; CHECK-LABEL: define i32 @and_ones(
; CHECK: entry:
; CHECK-NEXT: ret i32 %x
define i32 @and_ones(i32 %x) {
entry:
  %a = and i32 %x, -1
  ret i32 %a
}

; CHECK-LABEL: define i32 @or_zero(
; CHECK: entry:
; CHECK-NEXT: ret i32 %x
define i32 @or_zero(i32 %x) {
entry:
  %a = or i32 0, %x
  ret i32 %a
}

; CHECK-LABEL: define i32 @xor_zero(
; CHECK: entry:
; CHECK-NEXT: ret i32 %x
define i32 @xor_zero(i32 %x) {
entry:
  %a = xor i32 %x, 0
  ret i32 %a
}

; CHECK-LABEL: define i32 @shifts_zero(
; CHECK: entry:
; CHECK-NEXT: ret i32 %x
define i32 @shifts_zero(i32 %x) {
entry:
  %a = shl i32 %x, 0
  %b = lshr i32 %a, 0
  %c = ashr i32 %b, 0
  ret i32 %c
}

; CHECK-LABEL: define i32 @div_one(
; CHECK: entry:
; CHECK-NEXT: ret i32 %x
define i32 @div_one(i32 %x) {
entry:
  %a = udiv i32 %x, 1
  %b = sdiv i32 %a, 1
  ret i32 %b
}

; CHECK-LABEL: define i32 @chain(
; CHECK: entry:
; CHECK-NEXT: ret i32 %x
define i32 @chain(i32 %x) {
entry:
  %a = add i32 %x, 0
  %b = mul i32 %a, 1
  %c = xor i32 %b, 0
  ret i32 %c
}

; CHECK-LABEL: define i64 @wide_integer(
; CHECK: entry:
; CHECK-NEXT: ret i64 %x
define i64 @wide_integer(i64 %x) {
entry:
  %a = add i64 %x, 0
  %b = and i64 %a, -1
  ret i64 %b
}

