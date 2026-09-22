// v11u88 v5 -- the net DECLARATION carrying BOTH a strength and a delay, and
// a delay-only one beside it.
interface ifc ();
  wire [31:0] w_plain = 32'd11;
  wire [31:0] #2 w_dly = 32'd12;
  wire (strong1, weak0) [31:0] #3 w_both = 32'd13;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_plain ^ u_if.w_dly;
endmodule
