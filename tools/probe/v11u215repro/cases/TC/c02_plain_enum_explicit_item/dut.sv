// § pkgImportEnumCloneLastWriter215 — a plain enum imported by explicit item into two packages (source order r then q)
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef enum logic {X, Y} f_t;
endpackage
package r;
  import p::e_t;
  parameter e_t RP = p::A;
endpackage
package q;
  import p::f_t;
  import p::e_t;
  function automatic e_t fq(); return p::B; endfunction
endpackage
module m;
endmodule
