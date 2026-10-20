// § hoistNetsFirstModule418
package p;
  class c;
    int v;
    int w;
    extern function void f();
  endclass
  function void c::f();
    v = 1;
    w = v + 2;
  endfunction
endpackage
