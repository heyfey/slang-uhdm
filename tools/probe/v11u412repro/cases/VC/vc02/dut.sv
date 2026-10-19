// § classKwParamsLast412
class C #(type T = int, parameter N = 2, int M = 3, type U = bit);
  T x;
  U y;
endclass
module top;
  C c;
endmodule
