// § elabBasedLitLowerBase427
class C #(parameter P = 4'B1010);
  int x = P;
endclass
module top(output [15:0] o);
  parameter P = 4'B1100;
  assign o = P;
endmodule
