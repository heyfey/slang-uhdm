// § classParamWrittenKwTs424 (header parameters with non-constant defaults)
class C #(int A = 3, int B = A, parameter int D = A * 2, string S = "x", byte Y = 8'h1);
  int v = B + D;
endclass
module test;
  C #(4) c;
endmodule
