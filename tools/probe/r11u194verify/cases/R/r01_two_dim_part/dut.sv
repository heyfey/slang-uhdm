// § rootLvalueSpanAtRoot184: $root targets with two unpacked dimensions, a part select, an indexed part select and a call index
module top (input logic clk, input int k);
  logic [7:0] mem [4][4];
  logic [15:0] v;
  function automatic int fx(input int x); return x & 3; endfunction
  always @(posedge clk) begin
    $root.top.mem[1][2] <= 8'h5;
    $root.top.v[7:4] <= 4'h3;
    $root.top.v[k +: 2] <= 2'b10;
    $root.top.mem[fx(k)][0] <= 8'h1;
  end
endmodule
