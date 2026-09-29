// § pcwAllPkgListingBindsOwn224 (the cast inside a package function)
package p;
localparam dev_addr_width_gp = 20;
function automatic logic [dev_addr_width_gp-1:0] f(int x); return (dev_addr_width_gp)'(x); endfunction
endpackage
module top import p::*; (output logic [dev_addr_width_gp-1:0] o);
  assign o = f(5);
endmodule
