// § pkgImportEnumCloneLastWriter215 — a plain enum reaching two packages through a chain p -> q -> r
package p;
  typedef enum logic [1:0] {A, B} e_t;
endpackage
package q;
  import p::*;
  e_t qv;
endpackage
package r;
  import q::*;
  import p::*;
  class d; e_t z; endclass
endpackage
module m;
endmodule
