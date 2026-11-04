// § classParamBitsKeywordFold424
class C #(int N = $bits(int));
  localparam X = $bits(int) * 2;
  localparam Y = $bits(int unsigned);
endclass
module test; endmodule
