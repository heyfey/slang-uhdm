// § varDeclInitMovesSharedTsEnd297
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
endpackage
module dut import pk::*; (input logic [7:0] pa, output logic o);
  var t_t x = 8'h33;
  assign o = x.a[0] ^ pa[0];
endmodule
