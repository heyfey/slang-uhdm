// r11u88 z1 -- LAW B: an `assign` carrying BOTH a drive strength and a delay.
// `CompileHelper::compileContinuousAssignment` advances ONE sibling past the
// Drive_strength and then reads the Delay3 node as the net-assignment list, so
// the producer writes NO cont_assign at all.  We write one.
interface ifc ();
  logic [31:0] c_both;
  assign (pull1, supply0) #3 c_both = 32'd10;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.c_both;
endmodule
