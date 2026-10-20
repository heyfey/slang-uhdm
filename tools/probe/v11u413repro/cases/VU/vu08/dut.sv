// § superMemberHierPath413
class P;
  int value;
  int arr[4];
  typedef struct { int f; int g; } s_t;
  s_t s;
endclass
class L extends P;
  int value;
  function void f();
    super.value = super.value + value;
  endfunction
endclass
module top;
  L l;
  initial begin l = new; l.f(); end
endmodule
