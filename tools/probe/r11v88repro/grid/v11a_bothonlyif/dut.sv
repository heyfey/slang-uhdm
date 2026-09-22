// v11u88 v11a -- an INTERFACE whose ONLY cont_assign is the declined one.
interface ifc ();
  logic [31:0] c;
  assign (supply1, supply0) #4 c = 32'd7;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.c;
endmodule
