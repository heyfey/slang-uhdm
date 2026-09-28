// § callArgInSelIdxChainName201
module n01 (input logic clk, input logic [1:0] k, output logic [7:0] o);
  typedef struct packed { logic [3:0][2:0] f; } s_t;
  s_t s, t;
  logic [7:0] arr;
  logic [11:0] x;
  function automatic logic [2:0] fx(input logic [2:0] v); return v; endfunction
  always @(posedge clk) begin
    t.f[fx(s.f[k])] += 3'd1;
    t.f[fx(s.f[k])]++;
    --t.f[fx(s.f[k+1])];
    {>>{t.f[fx(s.f[k])]}} = x[2:0];
    arr[fx(s.f[k])] |= 1'b1;
  end
  assign o = arr;
endmodule
