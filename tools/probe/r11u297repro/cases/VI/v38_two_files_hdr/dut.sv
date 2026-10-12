// § varDeclInitMovesSharedTsEnd297
`include "td.svh"
module dut (input logic [7:0] pa, output logic o);
  var ht_t x = 8'h11;
  assign o = x.a[0] ^ pa[0];
endmodule
