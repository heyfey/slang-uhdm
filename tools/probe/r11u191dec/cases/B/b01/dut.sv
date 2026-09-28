// (r11u191 BlackBePipeInt N0923) a parenthesized size cast whose width is another package parameter, imported by a module
package pk;
  localparam dev_addr_width_gp = 20;
  localparam dev_match_gp = (dev_addr_width_gp)'('h0_c???);
  localparam plain_gp = (dev_addr_width_gp)'(5);
endpackage
module top import pk::*; (output logic [19:0] o, output logic [19:0] q);
  assign o = dev_match_gp;
  assign q = plain_gp;
endmodule
