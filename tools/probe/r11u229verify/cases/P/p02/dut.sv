// § pcwAllPkgListingBindsOwn224 (an import by name of the width parameter)
package p;
localparam dev_addr_width_gp = 20;
localparam getchar_base_addr_gp = (dev_addr_width_gp)'('h0_0000);
endpackage
module top (output logic [19:0] o);
  import p::dev_addr_width_gp;
  import p::getchar_base_addr_gp;
  logic [dev_addr_width_gp-1:0] w;
  assign w = getchar_base_addr_gp;
  assign o = w;
endmodule
