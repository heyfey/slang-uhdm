// § varDeclInitMovesSharedTsEnd297
module dut (input logic [7:0] pa, output logic o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  var t_t x [2] = '{8'h01, 8'h02};
  assign o = x[0].a[0] ^ pa[0];
endmodule
