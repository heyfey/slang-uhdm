// § modAliasTdAtBaseClone484 (module alias of an unpacked struct with a member default)
module top;
  typedef struct { int k = 3; int d; } op_t;
  typedef op_t op2_t;
  op2_t v;
  int x;
  initial begin v.d = 1; x = v.k + v.d; end
endmodule
