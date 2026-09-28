// § callArgInSelIdxChainName201
module top (input logic clk, input logic [1:0] k, input logic [2:0] q [4], output logic [7:0] o, output logic [2:0] o2);
  typedef struct packed { logic [3:0][2:0] f; } s_t;
  s_t s, t;
  logic [7:0] arr;
  function automatic logic [2:0] fx(input logic [2:0] x); return x; endfunction
  always @(posedge clk) begin
    t.f[fx(s.f[fx(t.f[k])])] <= 3'b0;
    t.f[fx(s.f[k]) + 1] <= 3'b1;
  end
  assign o = arr;
  assign o2 = t.f[0];
endmodule
