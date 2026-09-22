// two NON-SIMPLE interfaces, one class each -- design-root ordering across homes
interface inner (); wire [31:0] w = 32'd1; endinterface
interface ifz (); inner u1 (); class Zc; int z; endclass endinterface
interface ifa (); inner u2 (); class Ac; int a; endclass endinterface
module dut (output logic [31:0] o);
  ifz u_z (); ifa u_a ();
  assign o = 32'd0;
endmodule
