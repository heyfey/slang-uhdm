// § rootPathFullNameByChain181 § rootNetPathOwnNames181 § rootPathElemOwnName181 (r11u190: a $root path to a child NET as a continuous-assignment target and read back through $root)
module sub;
  wire [3:0] w;
endmodule
module top(input [3:0] a, output [3:0] y);
  sub u();
  assign $root.top.u.w = a;
  assign y = $root.top.u.w;
endmodule
