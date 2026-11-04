// § classParamBitsKeywordFold424
class C #(type T = int);
  localparam X = $bits(T);
  localparam Y = $bits(int);
endclass
module test; C #(byte) c; endmodule
