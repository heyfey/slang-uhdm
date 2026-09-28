// § lvIdxCallArgIsRead198 § tfFormalTdCloneFile196: a call in an lvalue index whose formal and return are a typedef from an included header, over a member select argument
`include "td.svh"
module top (input logic clk, input logic [1:0] k, output logic [7:0] o);
  typedef struct packed { logic [3:0][2:0] f; } s_t;
  s_t s;
  logic [7:0] arr;
  function automatic idx_t fx(input idx_t x); return x; endfunction
  always @(posedge clk) arr[fx(s.f[k])] <= 1'b1;
  assign o = arr;
endmodule
