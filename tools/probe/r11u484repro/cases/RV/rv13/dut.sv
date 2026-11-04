// § modAliasTdAtBaseClone484 (module variable of a module alias of a struct)
module top;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  op2_t acc;
  int x;
  assign x = acc.data;
endmodule
