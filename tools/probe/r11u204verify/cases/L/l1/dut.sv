// § lvIdxCallArgIsRead198: compound assignments ^=, <<=, -= whose lvalue index is a call over a member select
module top (input logic clk, input logic [1:0] k, output logic [7:0] o);
  typedef struct packed { logic [3:0][2:0] f; } s_t;
  s_t s;
  logic [7:0] arr [8];
  function automatic logic [2:0] fx(input logic [2:0] x); return x; endfunction
  always_ff @(posedge clk) begin
    arr[fx(s.f[k])] ^= 8'h1;
    arr[fx(s.f[k+1])] <<= 1;
    arr[fx(s.f[0])] -= 8'd2;
  end
  assign o = arr[0];
endmodule
