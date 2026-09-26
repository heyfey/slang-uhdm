// § patFlatMemberLeftSpan169
package pk;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } s_t;
  localparam s_t P = '{x: 3 + 4, y: 8'd2};
endpackage
module top (input logic a, output logic [7:0] b);
  assign b = a ? pk::P.x : pk::P.y;
endmodule
