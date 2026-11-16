
define i32 @calculate(i32 %x) {
entry:
  %a = add i32 %x, 0
  %b = mul i32 %a, 1
  %c = xor i32 %b, 0
  ret i32 %c
}

