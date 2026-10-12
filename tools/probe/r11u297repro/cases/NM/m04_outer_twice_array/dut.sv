// § nestedDefPortsNeedShell297
module outer (output logic [1:0] o);
  module inner (output logic r); assign r = 1'b1; endmodule
  inner u_i [1:0] (.r(o));
endmodule
module dut (output logic [3:0] o);
  outer u_o (.o(o[1:0]));
  outer u_p (.o(o[3:2]));
endmodule
