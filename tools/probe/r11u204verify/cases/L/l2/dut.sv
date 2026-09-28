// § lvIdxCallArgIsRead198: nested calls in an lvalue index, two call indices on one lvalue, a call as an indexed part-select base
module top (input logic clk, input logic [1:0] k, output logic [7:0] o, output logic [7:0] p);
  typedef struct packed { logic [3:0][2:0] f; } s_t;
  s_t s, t;
  logic [7:0] arr;
  logic [7:0] m [8][8];
  function automatic logic [2:0] fx(input logic [2:0] x); return x; endfunction
  function automatic logic [2:0] fy(input logic [2:0] x); return x + 1; endfunction
  always @(posedge clk) begin
    arr[fx(fy(s.f[k]))] <= 1'b1;
    m[fx(s.f[k])][fx(t.f[k])] <= 8'h3;
    arr[fx(s.f[k]) +: 2] <= 2'b10;
  end
  assign o = arr;
  assign p = m[0][0];
endmodule
