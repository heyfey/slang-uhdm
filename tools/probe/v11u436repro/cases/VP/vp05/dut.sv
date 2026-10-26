// § genClsNoDefPropRange436
class B; int x; endclass
class C #(int N) extends B;
  logic [N-1:0] v;
endclass
module top;
endmodule
