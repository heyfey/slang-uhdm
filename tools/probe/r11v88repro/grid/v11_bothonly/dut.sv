// v11u88 v11 -- an interface whose ONLY cont_assign is the declined one (the
// def listing goes EMPTY), and a module twin beside it.
interface ifc ();
  logic [31:0] c;
  assign (supply1, supply0) #4 c = 32'd7;
endinterface

module sub (output logic [31:0] y);
  assign (pull0, pull1) #1 y = 32'd8;
endmodule

module dut (output logic [31:0] o);
  ifc u_if ();
  logic [31:0] sy;
  sub u_s (.y(sy));
  assign o = u_if.c ^ sy;
endmodule
