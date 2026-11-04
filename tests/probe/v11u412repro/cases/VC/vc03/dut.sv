// § classKwParamsLast412
class C #(int A = 1, B = 2, parameter C2 = 3, D = 4);
  localparam L = A + C2;
  parameter P = 5;
endclass
module top;
  C c;
endmodule
