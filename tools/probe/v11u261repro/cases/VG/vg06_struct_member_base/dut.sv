// § pselConnArrPathName261
package gp;
  parameter int BW = 12;
  parameter int LB = 2;
endpackage
module leaf (input logic [9:0] addr_i, output logic o);
  assign o = ^addr_i;
endmodule
typedef struct packed { logic [15:0] ma; logic x; } s_t;
module core import gp::*; (input s_t s, output logic o);
  leaf i_flash (.addr_i(s.ma[BW-1:LB]), .o(o));
endmodule
module bank (input s_t a, output logic [1:0] o);
  for (genvar b = 0; b < 2; b++) begin : gen_banks
    core i_core (.s(a), .o(o[b]));
  end
endmodule
module top;
  s_t a; logic [1:0] o;
  bank u (.a(a), .o(o));
endmodule
