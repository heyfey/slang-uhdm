// § callArgInSelIdxChainName201
module top (input logic clk, input logic [1:0] k, input logic [2:0] q [4], output logic [7:0] o, output logic [2:0] o2);
  typedef struct packed { logic [3:0][2:0] f; } s_t;
  s_t s, t;
  logic [7:0] arr;
  function automatic logic [2:0] fx(input logic [2:0] x); return x; endfunction
  function automatic void g(input logic [1:0] j);
    t.f[fx(s.f[j])] = 3'b0;
  endfunction
  always @(posedge clk) g(k);
  assign o = arr;
  assign o2 = t.f[0];
endmodule
