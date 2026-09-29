// § pkgTdAliasLastWriter215 — a class-specialization alias read by a module, an interface and a program; a second specialization alias of the same class
package p;
  class C #(int N = 1); logic [N-1:0] v; endclass
  typedef C#(8) c8_t;
  typedef C#(4) c4_t;
  class user;
    function void f(c8_t a, c4_t b); endfunction
  endclass
endpackage
program pr;
  import p::*;
  c8_t h;
endprogram
interface ifc;
  import p::*;
  c4_t h;
endinterface
module m;
  import p::*;
  c8_t h;
  ifc u();
  pr u_pr();
endmodule
