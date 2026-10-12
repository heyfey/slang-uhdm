// § varDeclInitElabSpan297
module dut (input logic [7:0] pa, output logic o);
  var int x = 5, y = 6;
  assign o = x[0] ^ y[0] ^ pa[0];
endmodule
