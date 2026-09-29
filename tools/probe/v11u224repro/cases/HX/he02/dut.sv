// § hpLvNewClassFirstElemSpan224
package p;
  typedef logic [9:0] l_t;
  typedef struct { logic [7:0] v; } s_t;
  class s; endclass
  class r; s parent; endclass
  class m;
    s_t arr[4];
    extern function void f(r rw);
    extern function int h(int i, int k);
    function void g(r rw); f(rw); void'(h(1, 2)); endfunction
  endclass
  function int m::h(int i, int k);
    return $bits(l_t) + arr[i].v[k+:2];
  endfunction
  function void m::f(r rw);
    rw.parent = new();
  endfunction
endpackage
module top; endmodule
