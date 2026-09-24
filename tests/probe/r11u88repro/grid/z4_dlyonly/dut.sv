// r11u88 z4 -- the CONTROL for LAW B: a delay alone.  The producer writes the
// cell and carries the delay.
interface ifc ();
  logic [31:0] c_del;
  assign #5 c_del = 32'd8;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.c_del;
endmodule
