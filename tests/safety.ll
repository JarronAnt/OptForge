
; CHECK-LABEL: define i32 @non_identity(
; CHECK: entry:
; CHECK-NEXT: %a = add i32 %x, 5
; CHECK-NEXT: %b = mul i32 %a, 2
; CHECK-NEXT: %c = xor i32 %b, 7
; CHECK-NEXT: ret i32 %c
define i32 @non_identity(i32 %x) {
entry:
  %a = add i32 %x, 5
  %b = mul i32 %a, 2
  %c = xor i32 %b, 7
  ret i32 %c
}

; CHECK-LABEL: define i32 @mul_by_zero_is_not_handled(
; CHECK: entry:
; CHECK-NEXT: %a = mul i32 %x, 0
; CHECK-NEXT: ret i32 %a
define i32 @mul_by_zero_is_not_handled(i32 %x) {
entry:
  %a = mul i32 %x, 0
  ret i32 %a
}

; CHECK-LABEL: define i32 @preserve_side_effect(
; CHECK: entry:
; CHECK-NEXT: store volatile i32 %x, ptr %p, align 4
; CHECK-NEXT: ret i32 %x
define i32 @preserve_side_effect(ptr %p, i32 %x) {
entry:
  store volatile i32 %x, ptr %p, align 4
  %a = add i32 %x, 0
  ret i32 %a
}

