// § ownNamedAliasLocalIsRefVar484 (fixed array of a module alias in a module task)
module top;
  typedef union packed { logic [7:0] r; logic [7:0] q; } un_t;
  typedef un_t un2_t;
  task t(output logic [7:0] o);
    un2_t acc[2];
    acc[0].r = 8'h3;
    o = acc[0].q;
  endtask
  logic [7:0] x;
  initial t(x);
endmodule
