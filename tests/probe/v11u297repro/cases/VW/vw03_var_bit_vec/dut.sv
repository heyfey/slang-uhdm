// § varDeclInitElabSpan297
module dut(output logic [3:0] o);
  var bit [3:0] x = 4'h9;
  assign o = x;
endmodule
