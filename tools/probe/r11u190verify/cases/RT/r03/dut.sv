// § rootPathFullNameByChain181 § rootNetPathOwnNames181 § rootPathElemOwnName181 (r11u190: $root selects inside a class method and in a generate scope reading a generate-scope net through $root)
module top;
  int cnt [4];
  class C;
    function int g(int i); return $root.top.cnt[i] + $root.top.cnt[i+1]; endfunction
  endclass
  for (genvar i = 0; i < 2; i++) begin : G
    logic [3:0] r;
    logic [3:0] s;
    always_comb s = $root.top.G[i].r;
  end
  logic [3:0] t;
  assign t = $root.top.G[1].s;
endmodule
