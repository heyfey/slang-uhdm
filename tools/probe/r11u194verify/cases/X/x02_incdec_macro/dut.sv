// § incDecMemberSelIsLvalue184 § macroPathTokSpans183 § macroPathTokOneBuffer186: inc/dec member-select operands written through macros (the path in the body; the index an argument) in a generate-scope process and a function
`define INC(S, I) S.f[I]++;
`define DEC_BODY(S) S.g[0]--;
module top (input logic clk, input logic [1:0] k, output logic [7:0] o);
  typedef struct packed { logic [3:0][7:0] f; logic [1:0][7:0] g; } s_t;
  s_t s;
  function automatic void bump(input logic [1:0] j);
    `INC(s, j)
    `DEC_BODY(s)
  endfunction
  if (1) begin : g
    s_t t;
    always @(posedge clk) begin
      `INC(t, k)
      `DEC_BODY(t)
    end
  end
  always @(posedge clk) bump(k);
  assign o = s.f[0];
endmodule
