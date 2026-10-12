// § varDeclInitMovesSharedTsEnd297
module dut (input logic [7:0] pa, output logic o);
  var logic [7:0] x = 8'h12;
  assign o = x[0] ^ pa[0];
endmodule
