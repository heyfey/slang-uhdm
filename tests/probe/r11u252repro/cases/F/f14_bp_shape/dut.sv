// § impSizeCastFoldLocated252
package p;
  localparam dev_id_width_gp = 4;
  localparam dev_addr_width_gp = 20;
  localparam host_base_addr_gp = (dev_id_width_gp+dev_addr_width_gp)'('h0010_0000);
endpackage
module top import p::*; #(parameter X = 1) ();
endmodule
