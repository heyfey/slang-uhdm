// § forInitSelectLhsBase254 (a synthesizable always_comb loop over a struct member and an array element with a parameter bound)
typedef struct packed { logic [3:0] a; } s_t;
module top #(parameter int N = 4) (input logic [7:0] d, output logic [7:0] o);
  s_t s;
  logic [3:0] c [2];
  always_comb begin
    o = '0;
    for (s.a = 0; s.a < N; s.a++) o = o + d;
    for (c[0] = 0; c[0] < N; c[0]++) o = o ^ d;
  end
endmodule
