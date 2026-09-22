// v11u90 vy17 -- an interface instantiated INSIDE another interface: the
// delay-ref cell folds through two levels.
interface inner ();
  parameter int D = 4;
  logic [31:0] c;
  assign #D c = 32'd10;
endinterface
interface outer ();
  inner u_in ();
  logic [31:0] d;
  assign d = u_in.c;
endinterface
module dut (output logic [31:0] o);
  outer u_out ();
  assign o = u_out.d;
endmodule
