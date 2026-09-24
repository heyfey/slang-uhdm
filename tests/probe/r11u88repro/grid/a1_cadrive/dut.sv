// r11u85 a1 -- LAW A: the PRE-EXISTING elab-clone shape #1, a PLAIN-CONSTANT
// Rhs, crossed with the drive fields `cont_assign::Compare` reads BEFORE the
// Rhs.  The combined `(strength) #delay` form is NOT here: the producer drops
// that cell outright (arm a7_bothdrive), and GOLDEN WRITES NOTHING ON A MISS.
interface ifc ();
  logic [31:0] c_none;
  logic [31:0] c_del;
  logic [31:0] c_str;
  assign c_none = 32'd7;
  assign #5 c_del = 32'd8;
  assign (strong1, weak0) c_str = 32'd9;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.c_none ^ u_if.c_del ^ u_if.c_str;
endmodule
