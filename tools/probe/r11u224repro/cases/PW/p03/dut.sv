// r11u224 decode: the paren-cast width mark in the --elabuhdm view
package p;
localparam dev_id_width_gp   = 4;
localparam dev_addr_width_gp = 20;
localparam host_dev_gp  = 1;
localparam getchar_base_addr_gp = (dev_addr_width_gp)'('h0_0000);
endpackage
package q;
  import p::*;
  localparam int qq = 3;
endpackage
module top;
import p::*;
import q::*;
logic [dev_addr_width_gp-1:0] o;
endmodule
