// § genClsNoDefPropRange436
class C #(int N);
  logic [N-1:0] v;
endclass
module top;
  C #(4) h;
  initial h = new;
endmodule
