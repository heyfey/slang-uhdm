// § externProtoFormalsFromPrototype175
package p;
  class k;
    int v;
    extern function new(int a = 3, string s = "x");
  endclass
  function k::new(int a = 3, string s = "x");
    v = a;
  endfunction
endpackage
module top;
  import p::*;
  k o;
  initial o = new(7);
endmodule
