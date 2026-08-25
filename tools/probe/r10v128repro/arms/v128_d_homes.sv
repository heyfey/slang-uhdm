// r10v128 arm D — the HOME and the INSTANCE COUNT.  A class method, a free
// package function, a module `initial`, and a macro whose body invokes ANOTHER
// macro (nested expansion buffers); one, two and three instances per cell.
`include "v128_defs.svh"
package pkg_v128d;
  class cls_v128d;
    string q[$];
    string field[$];
    string abstractions[$];
    int rcv;
    cls_v128d ob_v;
    function void f_class_one();
      `V4_CELL(q)
    endfunction
    function void f_class_two();
      `V4_TWO(q, abstractions)
    endfunction
    function void f_class_three();
      `V4_THREE(q, field, abstractions)
    endfunction
    function void f_nested_macro();
      `V4_OUTER(q)
      `V4_OUTER(abstractions)
    endfunction
  endclass
  cls_v128d ob_v;
  string q[$];
  string abstractions[$];
  int rcv;
  function void free_v128d();
    `V4_CELL(q)
    `V4_CELL(abstractions)
  endfunction
endpackage
module top_v128d;
  import pkg_v128d::*;
  typedef struct { int a; } dummy_t;
  cls_v128d c;
  initial begin
    c = new();
    free_v128d();
  end
endmodule
module mod_v128d;
  import pkg_v128d::*;
  cls_v128d ob_v;
  string q[$];
  string abstractions[$];
  int rcv;
  initial begin
    `V4_CELL(q)
  end
endmodule
