// § pkgImportEnumCloneLastWriter215 — a plain enum imported by package q and by a module (module last), q's class uses it
package p;
  typedef enum logic [1:0] {A, B} e_t;
endpackage
package q;
  import p::*;
  class d; e_t z; endclass
endpackage
module m;
  import p::*;
  e_t v;
endmodule
