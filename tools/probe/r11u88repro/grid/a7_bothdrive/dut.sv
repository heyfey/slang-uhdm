// r11u85 a7 -- THE PRODUCER'S DECLINE, recorded not copied: an `assign` that
// carries BOTH a drive strength and a delay is written by neither interface
// view.  Golden lists 0 cont_assigns for it; we list one.  GOLDEN WRITES
// NOTHING ON A MISS -- this arm exists so the absence is measured, and no law
// of this pass touches it.
interface ifc ();
  logic [31:0] c_both;
  assign (pull1, supply0) #3 c_both = 32'd10;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.c_both;
endmodule
