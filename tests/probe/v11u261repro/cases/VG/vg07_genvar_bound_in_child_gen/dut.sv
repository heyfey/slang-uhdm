// § pselConnArrPathName261
package gp;
  parameter int BW = 12;
  parameter int LB = 2;
endpackage
module leaf (input logic [9:0] addr_i, output logic o);
  assign o = ^addr_i;
endmodule
module core import gp::*; (input logic [15:0] ma, output logic [1:0] o);
  for (genvar j = 0; j < 2; j++) begin : gj
    leaf i_flash (.addr_i(ma[BW-1-j:LB-j]), .o(o[j]));
  end
endmodule
module bank (input logic [15:0] a, output logic [3:0] o);
  for (genvar b = 0; b < 2; b++) begin : gen_banks
    core i_core (.ma(a), .o(o[2*b+:2]));
  end
endmodule
module top;
  logic [15:0] a; logic [3:0] o;
  bank u (.a(a), .o(o));
endmodule
