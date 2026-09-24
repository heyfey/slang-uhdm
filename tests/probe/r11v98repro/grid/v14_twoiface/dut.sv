// v14 -- two interfaces each with a class, plus a $unit class: design-root order.
class Mroot; int m; endclass
interface ifa ();
  class Zia; int z; endclass
endinterface
interface ifb ();
  class Aib; int a; endclass
endinterface
module dut (output logic [31:0] o);
  ifa u_a ();
  ifb u_b ();
  assign o = 32'd0;
endmodule
