// § pureVirtFormalSignKwTrim247
package p;
  virtual class base;
    pure virtual function void f(int unsigned a, logic [7:0] b);
    pure virtual task t(output int unsigned c, int unsigned d);
  endclass
  class d extends base;
    extern virtual function void f(int unsigned a, logic [7:0] b);
    extern virtual task t(output int unsigned c, int unsigned d);
  endclass
  function void d::f(int unsigned a, logic [7:0] b); endfunction
  task d::t(output int unsigned c, int unsigned d); c = d; endtask
endpackage
package q;
  import p::*;
  class u;
    function void g();
      d x;
      x = null;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  d z;
  u w;
endmodule
