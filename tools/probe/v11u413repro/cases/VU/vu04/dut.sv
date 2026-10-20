// § superMemberHierPath413
class P;
  int value;
  int arr[4];
  typedef struct { int f; int g; } s_t;
  s_t s;
endclass
class M extends P;
endclass
class L extends M;
  int k;
  function void f();
    k = super.value + 1;
  endfunction
endclass
module top;
endmodule
