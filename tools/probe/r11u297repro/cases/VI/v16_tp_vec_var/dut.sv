// § varDeclInitMovesSharedTsEnd297
module dut #(parameter type w_t = logic [7:0]) (input logic [7:0] pa, output logic o);
  var w_t x = 8'h5a;
  assign o = x[0] ^ pa[0];
endmodule
