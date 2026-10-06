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
module bank (input logic [15:0] a, output logic [3:0] o);
  for (genvar b = 0; b < 2; b++) begin : gb
    for (genvar c = 0; c < 2; c++) begin : gc
      core i_core (.ma(a), .o(o[2*b+c]));
    end
  end
endmodule
module top;
  logic [15:0] a; logic [3:0] o;
  bank u (.a(a), .o(o));
endmodule
