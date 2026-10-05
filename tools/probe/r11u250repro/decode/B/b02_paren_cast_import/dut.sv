// § pcwRefLastWriter250 (decode of BlackBePipeInt #190646: an imported package localparam written as a paren-cast; the fold location face is a residue)
package p;
  localparam dev_id_width_gp = 4;
  localparam dev_addr_width_gp = 20;
  localparam host_base_addr_gp = (dev_id_width_gp+dev_addr_width_gp)'('h0010_0000);
  localparam getchar_base_addr_gp = (dev_addr_width_gp)'('h0_1000);
endpackage
module top import p::*; (output logic [31:0] o, output logic [31:0] q);
  assign o = host_base_addr_gp;
  assign q = getchar_base_addr_gp;
endmodule
