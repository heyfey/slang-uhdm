// § varDeclInitMovesSharedTsEnd297
module dut (input logic [7:0] pa, output logic o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  if (1) begin : g
    var t_t x = 8'h11;
  end
  assign o = g.x.a[0] ^ pa[0];
endmodule
