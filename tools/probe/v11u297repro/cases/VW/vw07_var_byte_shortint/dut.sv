// § varDeclInitElabSpan297
module dut(output logic [7:0] o, output logic [15:0] p);
  var byte x = 8'sd3;
  static shortint y = 16'sd7;
  assign o = x;
  assign p = y;
endmodule
