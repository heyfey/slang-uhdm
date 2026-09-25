// § pselConnNameNotFrozen155
module child #(parameter int CW = 2) (input logic [CW-1:0] ci, output logic co); assign co = ^ci; endmodule
module top (input logic [7:0] in_i, output logic c_o);
  typedef struct packed { logic [7:0] f; } s_t;
  s_t sv;
  assign sv.f = in_i;
  if (1) begin : g
    child #(.CW(4)) u_c (.ci(sv.f[3:0]), .co(c_o));
  end
endmodule
