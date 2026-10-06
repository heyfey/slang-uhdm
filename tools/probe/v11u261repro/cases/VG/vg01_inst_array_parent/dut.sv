// § pselConnArrPathName261
package gp;
  parameter int BW = 12;
  parameter int LB = 2;
endpackage
module leaf (input logic [9:0] addr_i, output logic o);
  assign o = ^addr_i;
endmodule
module core import gp::*; (input logic [15:0] ma, output logic o);
  leaf i_flash (.addr_i(ma[BW-1:LB]), .o(o));
endmodule
module top;
  logic [15:0] a; logic [1:0] o;
  core i_core [1:0] (.ma(a), .o(o));
endmodule
