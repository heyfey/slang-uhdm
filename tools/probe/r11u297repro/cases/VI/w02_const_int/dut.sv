// § varDeclInitElabSpan297
module dut (input logic [7:0] pa, output logic o);
  const int x = 5;
  assign o = x[0] ^ pa[0];
endmodule
