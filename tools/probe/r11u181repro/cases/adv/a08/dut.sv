// § procLvIdxCallWholeSpan181 — break hunt: a nonblocking lvalue, a part-select lvalue base, a streaming lvalue, a generate continuous assignment (control) and a system call index
module top(input logic clk, input int k);
  logic [7:0] arr [8];
  logic [31:0] v;
  logic [7:0] ga [4];
  function automatic int f(int a); return a; endfunction
  always_ff @(posedge clk) arr[f(k)] <= 8'd1;
  always_comb begin
    v = '0;
    v[f(k) +: 4] = 4'hF;
    {>>{arr[f(k)+1]}} = 8'd2;
    v[$clog2(k)] = 1'b1;
  end
  for (genvar g = 0; g < 2; g++) begin : G
    assign ga[f(g)] = 8'd3;
  end
endmodule
