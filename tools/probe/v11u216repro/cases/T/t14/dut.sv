// § tfArgImportCloneFollows216 — a program and a module importing p beside an outside class; the module also declares an e_t variable
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
package q;
  import p::*;
  class M;
    function void h(e_t z); endfunction
  endclass
endpackage
program pr;
  import p::*;
  e_t s;
endprogram
module top;
  import p::*;
  e_t v;
  pr u();
endmodule
