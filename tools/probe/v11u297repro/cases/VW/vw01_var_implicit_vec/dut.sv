// § varDeclInitElabSpan297
module dut(output logic [3:0] o);
  var [3:0] x = 4'h2;
  assign o = x;
endmodule
