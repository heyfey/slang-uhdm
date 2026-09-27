// § externProtoFormalsFromPrototype175
package p;
  class b;
    extern virtual function int g(int x, bit [2:0] y = 3'd5);
    extern static task s(output int o, input int q[$]);
  endclass
  function int b::g(int x, bit [2:0] y = 3'd5);
    return x + y;
  endfunction
  task b::s(output int o, input int q[$]);
    o = q.size();
  endtask
  class d extends b;
    virtual function int g(int x, bit [2:0] y = 3'd1);
      return x - y;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  d o; int r, n; int q[$];
  initial begin o = new; r = o.g(2); b::s(n, q); end
endmodule
