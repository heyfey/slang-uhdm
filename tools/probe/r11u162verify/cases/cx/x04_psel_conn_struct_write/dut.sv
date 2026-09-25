// § pselConnNameNotFrozen155 § lvPathBaseAtFirstMember154
module child #(parameter int CW = 2) (input logic clk, input logic [CW-1:0] ci, output logic [15:0] co);
  typedef struct packed { logic [7:0] wdtxx; logic [7:0] q; } s_t;
  s_t sv;
  always_ff @(posedge clk) sv.wdtxx[CW-1:0] <= ci;
  assign co = sv;
endmodule
module top(input logic clk, input logic [7:0] in_i, output logic [15:0] o);
  for (genvar k = 0; k < 1; k++) begin : gl
    child #(.CW(4)) u_c (.clk(clk), .ci(in_i[k*4+3:k*4]), .co(o));
  end
endmodule
