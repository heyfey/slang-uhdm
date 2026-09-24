// r11u88 q10 -- LAW A x LISTING ORDER: a written `assign` BEFORE the net
// declaration assignments and one after.  Does the producer list the
// net-decl-assign cells first (the module home's order) or in source order?
interface ifc ();
  logic [31:0] c_first;
  assign c_first = 32'd1;
  wire [31:0] w_mid = 32'd2;
  logic [31:0] c_last;
  assign c_last = 32'd3;
  wire [31:0] w_end = 32'd4;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.c_first ^ u_if.w_mid ^ u_if.c_last ^ u_if.w_end;
endmodule
