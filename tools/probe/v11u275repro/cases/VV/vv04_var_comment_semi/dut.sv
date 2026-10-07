// § tpTypedVarInitNameSpan275 — a var declaration whose preceding text holds a semicolon in a comment
module dut #(parameter type T = logic [3:0]) (output logic [3:0] o);
  var /* ; */ T x = 4'h5;
  assign o = x;
endmodule
