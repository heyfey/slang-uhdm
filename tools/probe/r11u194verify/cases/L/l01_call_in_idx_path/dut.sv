// § lvIdxMemberSelIsRead184 § nestRdIdxOnly190v: a member path ending in a select nested in an lvalue index whose own index is a call, a call argument wrapping the member path, and a two-dimensional target
module top (input logic clk, input logic [1:0] k, output logic [7:0] o);
  typedef struct packed { logic [3:0][1:0] f; } s_t;
  s_t s;
  logic [7:0] arr;
  logic [3:0][3:0] m2;
  function automatic logic [2:0] fx(input logic [1:0] x); return {1'b0, x}; endfunction
  always @(posedge clk) begin
    arr[s.f[fx(k)]] <= 1'b1;
    arr[fx(s.f[k])] <= 1'b0;
    m2[s.f[k]][s.f[(k)]] <= 1'b1;
  end
  assign o = arr;
endmodule
