// § superMemberHierPath413
class P;
  int value;
  int arr[4];
  typedef struct { int f; int g; } s_t;
  s_t s;
endclass
class L extends P;
  int k;
  extern function void f();
endclass
function void L::f();
  k = super.value;
endfunction
module top;
endmodule
