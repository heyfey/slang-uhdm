// r10v107 arm b7 — ONE WIRE PER NAME, WHICH SPAN?  MEASUREMENT ONLY.
// bindHoistedClassPropRefs mints one wire per NAME at the span of the FIRST
// pool entry of that name.  Two out-of-body methods declare a `ref_var` local
// with the SAME name and both references are now handed to that pool; golden
// decides how many wires exist and which span the survivor carries.
package pb7;

  class d7;
    int fld;
  endclass

  class snk7;
    function int ask(d7 v); return 0; endfunction
  endclass

  class c7 #(type T = d7);
    snk7 s;
    d7   plain;
    extern function void meth_a7();
    extern function void meth_b7();
    extern function void meth_c7();
  endclass

  function void c7::meth_a7();
    T collide7;
    if (s.ask(collide7) == 0) begin
    end
  endfunction

  function void c7::meth_b7();
    T collide7;
    if (s.ask(collide7) != 1) begin
    end
  endfunction

  function void c7::meth_c7();
    T collide7;
    collide7 = plain;
  endfunction

endpackage

module topb7;
  import pb7::*;
  c7 #(d7) inst;
  initial inst = new();
endmodule
