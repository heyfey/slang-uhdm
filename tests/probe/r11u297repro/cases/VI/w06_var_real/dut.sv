// § varDeclInitElabSpan297
module dut (input logic [7:0] pa, output logic o);
  var real r = 1.5;
  assign o = pa[0];
endmodule
