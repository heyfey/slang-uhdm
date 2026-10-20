// § superMemberHierPath413
class P;
  int value;
  int arr[4];
  typedef struct { int f; int g; } s_t;
  s_t s;
endclass
class L extends P;
  rand int y;
  constraint c { y < super.value; }
endclass
module top;
endmodule
