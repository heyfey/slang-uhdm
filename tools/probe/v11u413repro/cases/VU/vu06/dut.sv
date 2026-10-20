// § superMemberHierPath413
class P;
  int value;
  int arr[4];
  typedef struct { int f; int g; } s_t;
  s_t s;
endclass
class L extends P;
  int k;
  function int g(int a);
    return a;
  endfunction
  function void f();
    k = g(super.value);
  endfunction
endclass
module top;
endmodule
