// § patFlatMemberLeftSpan169
module top #(parameter int A = 3) (input logic a, output logic [7:0] b);
  typedef struct packed { logic [7:0] p; logic [7:0] r; } in_t;
  typedef struct packed { in_t u; logic [7:0] v; } mid_t;
  typedef struct packed { mid_t m; logic [7:0] z; } it_t;
  localparam it_t I = '{m: '{u: '{p: A + 1, r: -A}, v: (A << 1) - 1}, z: A * 3};
  assign b = a ? I.m.u.p : I.z;
endmodule
