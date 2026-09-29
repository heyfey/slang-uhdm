// § pcwAllPkgListingBindsOwn224 (two modules import the package; a cast of the width parameter)
package p;
localparam dev_addr_width_gp = 20;
localparam getchar_base_addr_gp = (dev_addr_width_gp)'('h0_0000);
endpackage
module m1 import p::*; (output logic [dev_addr_width_gp-1:0] o); assign o = getchar_base_addr_gp; endmodule
module m2 import p::*; (output logic [dev_addr_width_gp-1:0] o); assign o = '0; endmodule
module top(output logic [19:0] a, output logic [19:0] b);
  m1 u1(.o(a));
  m2 u2(.o(b));
endmodule
