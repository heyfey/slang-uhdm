// § varDeclInitMovesSharedTsEnd297
module dut (input logic [7:0] pa, output logic o);
  typedef struct packed { logic [1:0] a; logic [1:0] b; } t_t;
  t_t [1:0] x = 8'h5a;
  assign o = x[0].a[0] ^ pa[0];
endmodule
