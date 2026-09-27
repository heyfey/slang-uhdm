// § rootPathFullNameByChain181 § rootNetPathOwnNames181 (r11u190: $root paths through function-like macros taking the selects as arguments)
`define RP(x) $root.top.x
`define RP2(a, i) $root.top.a[i]
module top;
  logic [7:0] mem [0:3][0:1];
  logic [7:0] q;
  int k;
  initial begin
    q = `RP(mem[1][1]);
    q = `RP2(mem, k)[0];
  end
endmodule
