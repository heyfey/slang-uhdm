// § parenCastWidthRefPkgBare207
package cp;
  localparam dev_addr_width_gp = 20;
  localparam b0_gp = (dev_addr_width_gp)'('h0_4000);
endpackage
package bp;
  import cp::*;
  localparam w_gp = dev_addr_width_gp + 1;
endpackage
module top(output logic [31:0] y);
  import cp::*;
  import bp::*;
  assign y = w_gp + dev_addr_width_gp;
endmodule
