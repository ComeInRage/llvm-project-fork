; RUN: opt < %s -passes=inverse-plus-minus -S | FileCheck %s

; CHECK-LABEL: define i32 @test(i32 %a, i32 %b) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    %a.addr = alloca i32, align 4
; CHECK-NEXT:    %b.addr = alloca i32, align 4
; CHECK-NEXT:    store i32 %a, ptr %a.addr, align 4
; CHECK-NEXT:    store i32 %b, ptr %b.addr, align 4
; CHECK-NEXT:    %0 = load i32, ptr %a.addr, align 4
; CHECK-NEXT:    %1 = load i32, ptr %b.addr, align 4
; CHECK-NEXT:    %add = add nsw i32 %0, %1
; CHECK-NEXT:    ret i32 %add
; CHECK-NEXT:  }

define i32 @test(i32 %a, i32 %b) {
entry:
  %a.addr = alloca i32, align 4
  %b.addr = alloca i32, align 4
  store i32 %a, ptr %a.addr, align 4
  store i32 %b, ptr %b.addr, align 4
  %0 = load i32, ptr %a.addr, align 4
  %1 = load i32, ptr %b.addr, align 4
  %add = add nsw i32 %0, %1
  ret i32 %add
}

; CHECK-LABEL: define i32 @replace(i32 %a, i32 %b) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    %a.addr = alloca i32, align 4
; CHECK-NEXT:    %b.addr = alloca i32, align 4
; CHECK-NEXT:    store i32 %a, ptr %a.addr, align 4
; CHECK-NEXT:    store i32 %b, ptr %b.addr, align 4
; CHECK-NEXT:    %0 = load i32, ptr %a.addr, align 4
; CHECK-NEXT:    %1 = load i32, ptr %b.addr, align 4
; CHECK-NEXT:    %inc = sub i32 %1, 1
; CHECK-NEXT:    store i32 %inc, ptr %b.addr, align 4
; CHECK-NEXT:    %call = call i32 @test(i32 %0, i32 %1)
; CHECK-NEXT:    ret i32 %call
; CHECK-NEXT:  }

define i32 @replace(i32 %a, i32 %b) {
entry:
  %a.addr = alloca i32, align 4
  %b.addr = alloca i32, align 4
  store i32 %a, ptr %a.addr, align 4
  store i32 %b, ptr %b.addr, align 4
  %0 = load i32, ptr %a.addr, align 4
  %1 = load i32, ptr %b.addr, align 4
  %inc = add nsw i32 %1, 1
  store i32 %inc, ptr %b.addr, align 4
  %call = call i32 @test(i32 %0, i32 %1)
  ret i32 %call
}

; CHECK-LABEL: define i32 @main() {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    %retval = alloca i32, align 4
; CHECK-NEXT:    %a = alloca i32, align 4
; CHECK-NEXT:    %b = alloca i32, align 4
; CHECK-NEXT:    store i32 0, ptr %retval, align 4
; CHECK-NEXT:    store i32 2, ptr %a, align 4
; CHECK-NEXT:    store i32 3, ptr %b, align 4
; CHECK-NEXT:    %0 = load i32, ptr %a, align 4
; CHECK-NEXT:    %1 = load i32, ptr %b, align 4
; CHECK-NEXT:    %call = call i32 @test(i32 %0, i32 %1)
; CHECK-NEXT:    %2 = load i32, ptr %a, align 4
; CHECK-NEXT:    %3 = load i32, ptr %b, align 4
; CHECK-NEXT:    %call1 = call i32 @replace(i32 %2, i32 %3)
; CHECK-NEXT:    %sub = sub nsw i32 %call, %call1
; CHECK-NEXT:    ret i32 %sub
; CHECK-NEXT:  }


define i32 @main() {
entry:
  %retval = alloca i32, align 4
  %a = alloca i32, align 4
  %b = alloca i32, align 4
  store i32 0, ptr %retval, align 4
  store i32 2, ptr %a, align 4
  store i32 3, ptr %b, align 4
  %0 = load i32, ptr %a, align 4
  %1 = load i32, ptr %b, align 4
  %call = call i32 @test(i32 %0, i32 %1)
  %2 = load i32, ptr %a, align 4
  %3 = load i32, ptr %b, align 4
  %call1 = call i32 @replace(i32 %2, i32 %3)
  %sub = sub nsw i32 %call, %call1
  ret i32 %sub
}
