// § patFlatMemberLeftSpan169
package pk;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } it_t;
endpackage
module top #(parameter int A = 3, parameter pk::it_t I = '{x: A + 1, y: A - 1}) (input logic a, output logic [7:0] b);
  assign b = a ? I.x : I.y;
endmodule
