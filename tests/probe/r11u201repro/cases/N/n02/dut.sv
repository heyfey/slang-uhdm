// § callArgInSelIdxChainName201
module top (input logic clk, input logic [1:0] k, input logic [2:0] q [4], output logic [7:0] o, output logic [2:0] o2);
  typedef struct packed { logic [3:0][2:0] f; } s_t;
  s_t s, t;
  logic [7:0] arr;
  function automatic logic [2:0] fx(input logic [2:0] x); return x; endfunction
  logic [2:0] r1, r2;
  always_comb begin
    r1 = t.f[fx(s.f[k])];
    r2 = arr[fx(s.f[k])];
  end
  assign o = arr;
  assign o2 = r1 ^ r2;
endmodule
