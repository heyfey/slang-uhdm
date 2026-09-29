// § pkgTdAliasLastWriter215 — two modules and two interfaces whose name order is not their source order, and a program named before them
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  class c;
    function void set(alias_t v, g_int_t w); endfunction
  endclass
endpackage
module zm; import p::*; endmodule
interface bi; import p::*; endinterface
module am; import p::*; endmodule
interface yi; import p::*; endinterface
program aprg; import p::*; endprogram
module top; zm z(); am a(); bi b(); yi y(); aprg pp(); endmodule
