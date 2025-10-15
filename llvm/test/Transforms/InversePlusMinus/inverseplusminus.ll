; RUN: opt < %s -passes=inverse-plus-minus -S | FileCheck %s

; CHECK-LABEL: define i32 @add_to_sub() {
; CHECK-NEXT:     %a1 = sub i32 3, 3
; CHECK-NEXT:     ret i32 %a
; CHECK-NEXT: }

define i32 @add_to_sub() {
  %a = add i32 3, 3
  ret i32 %a
}

; CHECK-LABEL: define i32 @sub_to_add() {
; CHECK-NEXT:     %a1 = add i32 3, 3
; CHECK-NEXT:     ret i32 %a
; CHECK-NEXT: }

define i32 @sub_to_add() {
  %a = sub i32 3, 3
  ret i32 %a
}
