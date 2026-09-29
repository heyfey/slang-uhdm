// § hpLvNewClassFirstElemSpan224
package p;
  typedef logic [9:0] l_t;
  typedef struct { logic [7:0] v; } s_t;
  class s; endclass
  class r; s parent; endclass
  virtual class base;
    pure virtual function void f(r rw);
  endclass
  class m extends base;
    s_t arr[4];
    function void g(r rw); f(rw); endfunction
    extern virtual function void f(r rw);
    extern function int h(int i, int k);
  endclass
  function void m::f(r rw);
    rw.parent = new;
  endfunction
  function int m::h(int i, int k);
    return $bits(l_t) + arr[i].v[k+:2];
  endfunction
endpackage
module top; endmodule
