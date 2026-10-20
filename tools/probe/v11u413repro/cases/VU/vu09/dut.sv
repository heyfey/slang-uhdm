// § superMemberHierPath413
class P;
  int value;
  int arr[4];
  typedef struct { int f; int g; } s_t;
  s_t s;
endclass
class L extends P;
  bit [1:0] k;
  function void f();
    k = super.value[1:0];
  endfunction
endclass
module top;
endmodule
