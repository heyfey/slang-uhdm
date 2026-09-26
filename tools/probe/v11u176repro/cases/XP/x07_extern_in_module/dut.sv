// § externProtoFormalsFromPrototype175
module top;
  class k;
    extern function int f(int a, bit [1:0] b);
  endclass
  function int k::f(int a, bit [1:0] b);
    return a + b;
  endfunction
  k o; int r;
  initial begin o = new; r = o.f(1, 2'd1); end
endmodule
