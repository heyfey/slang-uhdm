// § patFlatMemberLeftSpan169
module top #(parameter int W = 8, parameter int A = 3) (input logic a, output logic [W-1:0] b);
  typedef struct packed { logic [3:0] u; logic [3:0] v; } in_t;
  typedef struct packed { in_t x; logic [W-9:0] z; } it_t;
  localparam it_t I = '{x: '{u: A + 1, v: A - 1}, z: A * 3};
  assign b = a ? I.x : I.z;
endmodule
