// § contAssignLhsTsUnparented134
module top(input logic c, output logic [3:0] o);
  typedef struct packed { logic [3:0] x; logic y; } s_t;
  for (genvar g = 0; g < 2; g++) begin : gb
    s_t q;
    assign q = '{x: g, y: c};
  end
  assign o = gb[0].q.x ^ gb[1].q.x;
endmodule
