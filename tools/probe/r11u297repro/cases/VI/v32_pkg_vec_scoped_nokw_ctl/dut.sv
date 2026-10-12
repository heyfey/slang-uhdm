// § varDeclInitMovesSharedTsEnd297
package pk;
  typedef logic [7:0] w_t;
endpackage
module dut (input logic [7:0] pa, output logic o);
  pk::w_t x = 8'h33;
  assign o = x[0] ^ pa[0];
endmodule
