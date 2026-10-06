// § pselConnArrPathName261
package gp;
  parameter int BW = 12;
  parameter int LB = 2;
endpackage
module leaf (input logic [9:0] addr_i, output logic o);
  assign o = ^addr_i;
endmodule
module core (input logic [15:0] ma, output logic o);
  leaf i_flash (.addr_i(ma[gp::BW-1:gp::LB]), .o(o));
endmodule
module bank (input logic [15:0] a, output logic [1:0] o);
  for (genvar b = 0; b < 2; b++) begin : gen_banks
    core i_core (.ma(a), .o(o[b]));
  end
endmodule
module top;
  logic [15:0] a; logic [1:0] o;
  bank u (.a(a), .o(o));
endmodule
