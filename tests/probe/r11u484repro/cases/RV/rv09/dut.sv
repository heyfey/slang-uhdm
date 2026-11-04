// § ownNamedAliasLocalIsRefVar484 (module task local of a module alias of a union)
module top;
  typedef union packed { int k; bit [31:0] data; } op_t;
  typedef op_t op2_t;
  int x;
  task t(int n);
    op2_t acc;
    acc.k = n;
    x = acc.data;
  endtask
  initial t(1);
endmodule
