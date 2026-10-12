// § varDeclInitElabSpan297
module dut (input logic [7:0] pa, output logic o);
  var string s = "ab";
  assign o = pa[0];
endmodule
