// v11u77 ve -- the INTERFACE road.  emitInterfaceDef's hoisted-array_net loop
// walks the merged listing INDEX-ALIGNED with the def-view `nets` vector, and
// LAW A splices package NETS into that listing.  A package net and a package
// unpacked array are both imported into an interface here, with a plain
// variable between them so a misalignment shows as a wrong name.
package pi;
  logic [7:0] i_var;
  wire  [7:0] i_net;
  logic [7:0] i_arr [0:1];
  typedef struct packed { logic [3:0] a; logic [3:0] b; } is_t;
  is_t        i_st;
endpackage

interface ifc;
  import pi::*;
  logic [7:0] own;
endinterface

module dut (output logic [31:0] o);
  import pi::*;
  ifc u_if();
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] i_var; assign i_var = 32'd1;
    logic [31:0] i_net; assign i_net = 32'd2;
    logic [31:0] i_arr; assign i_arr = 32'd3;
    logic [31:0] i_st;  assign i_st  = 32'd4;
  end
  assign o = gv[0].i_var ^ gv[0].i_net ^ gv[0].i_arr ^ gv[0].i_st
           ^ {24'd0, u_if.own};
endmodule
