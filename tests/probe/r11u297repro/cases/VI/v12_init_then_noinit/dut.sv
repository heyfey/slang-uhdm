// § varDeclInitMovesSharedTsEnd297
module dut (input logic [7:0] pa, output logic o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  var t_t x = 8'h01, y;
  assign y = pa;
  assign o = x.a[0] ^ y.a[0];
endmodule
