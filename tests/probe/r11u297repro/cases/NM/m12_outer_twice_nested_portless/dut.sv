// § nestedDefPortsNeedShell297
module outer (output logic o);
  module inner; logic w; assign w = 1'b1; endmodule
  inner u_i ();
  assign o = 1'b0;
endmodule
module dut (output logic [1:0] o);
  outer u_o (.o(o[0]));
  outer u_p (.o(o[1]));
endmodule
