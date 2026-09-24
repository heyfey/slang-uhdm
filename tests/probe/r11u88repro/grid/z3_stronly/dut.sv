// r11u88 z3 -- the CONTROL for LAW B: a strength alone.  The producer writes
// the cell and carries both strengths.
interface ifc ();
  logic [31:0] c_str;
  assign (strong1, weak0) c_str = 32'd9;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.c_str;
endmodule
