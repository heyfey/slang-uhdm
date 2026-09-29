// § pcwAllPkgListingBindsOwn224 (no import: the module reads the package parameter qualified)
package p;
localparam dev_addr_width_gp = 20;
localparam getchar_base_addr_gp = (dev_addr_width_gp)'('h0_0000);
endpackage
module top (output logic [p::dev_addr_width_gp-1:0] o);
  assign o = p::getchar_base_addr_gp;
endmodule
