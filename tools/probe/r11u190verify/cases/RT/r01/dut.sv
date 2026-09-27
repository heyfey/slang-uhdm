// § rootPathFullNameByChain181 § rootNetPathOwnNames181 § rootPathElemOwnName181 (r11u190: $root reads with two dimensions, a part select, a call index and an indexed part select)
module top;
  logic [7:0] mem [0:3][0:1];
  logic [15:0] v;
  logic [7:0] q;
  function automatic int f(int a); return a; endfunction
  initial begin
    q = $root.top.mem[1][0];
    q = $root.top.v[11:4];
    q = $root.top.mem[f(2)][1];
    q = $root.top.v[f(0)+:8];
  end
endmodule
