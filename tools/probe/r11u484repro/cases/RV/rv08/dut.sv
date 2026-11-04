// § ownNamedAliasLocalIsRefVar484 (initial block local of a module alias of a struct)
module top;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  int x;
  initial begin
    op2_t acc;
    acc.k = 1;
    x = acc.data;
  end
endmodule
