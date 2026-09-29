// § tfArgOutsideClassOrder216 — outside classes in a program and in an interface (the program's class a writer?) beside another package's class
package p;
  typedef enum logic [1:0] {A0, B0, C0} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
package q;
  import p::*;
  class N;
    function void h(e_t z); endfunction
  endclass
endpackage
program prg;
  import p::*;
  class PC;
    function void pc(e_t w); endfunction
  endclass
endprogram
module top;
  import p::*;
  e_t v;
  prg u_prg();
endmodule
