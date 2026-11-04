// § classParamBitsKeywordFold424
class C;
  localparam A = $bits(byte);
  localparam B = $bits(logic [3:0]) + 1;
  parameter int D = $bits(longint) / 2;
endclass
module test;
endmodule
