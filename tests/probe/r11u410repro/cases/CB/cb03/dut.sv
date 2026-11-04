// § classPropBasedLitKept410
class C;
  const int a = 4'hf;
  static int b = 2'b10;
  rand int c = 32'h10;
  int d = 5;
endclass
module top;
  C h;
  initial h = new;
endmodule
