// § xzOvLitKeepsText427
class C #(parameter P = 0);
  static int v = P;
endclass
module top(output int o);
  assign o = C#(4'b1x)::v;
endmodule
