// § tfArgImportCloneFollows216 — a module importing p and an interface importing p beside an outside class (the importer clones)
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
  function automatic e_t r(input int i); return e_t'(i); endfunction
endpackage
package q;
  import p::*;
  class M;
    function void h(e_t z); endfunction
  endclass
endpackage
interface ifc;
  import p::*;
  e_t s;
endinterface
module top;
  import p::*;
  ifc u();
  e_t v;
  initial v = r(1);
endmodule
