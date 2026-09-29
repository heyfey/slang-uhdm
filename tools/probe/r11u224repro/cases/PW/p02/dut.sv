// r11u224 decode: the paren-cast width mark in the --elabuhdm view
package p;
localparam dev_id_width_gp   = 4;
localparam dev_addr_width_gp = 20;
localparam host_dev_gp  = 1;
localparam getchar_base_addr_gp = (dev_addr_width_gp)'('h0_0000);
endpackage
module top import p::*; (output logic [dev_addr_width_gp-1:0] o);
assign o = '0;
endmodule
