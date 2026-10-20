// § superMemberHierPath413
class P;
  int value;
  int arr[4];
  typedef struct { int f; int g; } s_t;
  s_t s;
endclass
class L extends P;
  function int d();
    return super.arr[1];
  endfunction
endclass
module top;
endmodule
