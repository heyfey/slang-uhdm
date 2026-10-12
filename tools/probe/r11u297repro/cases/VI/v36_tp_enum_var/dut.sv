// § varDeclInitMovesSharedTsEnd297
module dut #(parameter type e_t = enum logic [1:0] { A, B, C }) (input logic [7:0] pa, output logic o);
  var e_t s = e_t'(1);
  assign o = s[0] ^ pa[0];
endmodule
