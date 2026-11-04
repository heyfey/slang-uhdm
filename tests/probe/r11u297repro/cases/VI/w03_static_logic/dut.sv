// § varDeclInitElabSpan297
module dut (input logic [7:0] pa, output logic o);
  static logic [3:0] x = 4'h5;
  assign o = x[0] ^ pa[0];
endmodule
