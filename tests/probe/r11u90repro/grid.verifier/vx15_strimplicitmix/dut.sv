// v11u90 vx15 -- a strength declaration with NO explicit data type (implicit
// net type) beside an implicitly-created net.
module sub (output logic [31:0] o);
  wire (strong1, weak0) w_str = 1'b1;
  wire w_plain = 1'b0;
  assign o = {31'd0, w_plain};
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
