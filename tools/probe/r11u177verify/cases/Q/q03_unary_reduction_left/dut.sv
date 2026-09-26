// § patFlatMemberLeftSpan169
module top #(parameter int W = 8, parameter int A = 3) (input logic a, output logic [W-1:0] b);
  function automatic int f(int v); return v + 1; endfunction
  typedef struct packed {
    logic [W-1:0] x;
    logic [W-1:0] y;
  } it_t;
  localparam it_t I = '{x: &A[1:0] + 1, y: ~(A + 1)};
  assign b = a ? I.x : I.y;
endmodule
