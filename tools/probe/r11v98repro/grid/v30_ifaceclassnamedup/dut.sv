// v30 -- TWO interfaces declaring the SAME class name, plus a $unit class.
class Cdup; int u; endclass
interface ifa ();
  class Cdup; int a; endclass
endinterface
interface ifb ();
  class Cdup; int b; endclass
endinterface
module dut (output logic [31:0] o);
  ifa u_a ();
  ifb u_b ();
  assign o = 32'd0;
endmodule
