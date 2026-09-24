// § contAssignLhsTsUnparented134
module top(input logic c, output logic [3:0] o);
  typedef struct packed { logic [3:0] x; logic y; } s_t;
  s_t arr [2];
  assign arr[0] = '{x: 4'h3, y: c};
  assign arr[1] = '{x: 4'h4, y: c};
  assign o = arr[0].x ^ arr[1].x;
endmodule
