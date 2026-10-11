// § withCallParenSyntax286
class C;
  rand int a;
endclass
module top;
  C o;
  int ok;
  initial begin o = new; ok = 1 + (o.randomize(a) with {a > 0;}); end
endmodule
