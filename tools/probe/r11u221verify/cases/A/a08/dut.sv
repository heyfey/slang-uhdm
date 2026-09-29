// § enumCloneValueItemKeepsBare215v + § pkgImportEnumCloneLastWriter215 — a value-item import in a package that another package wildcard-imports, and a module importing both packages
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
package q;
  import p::B;
  parameter logic [1:0] QB = B;
endpackage
package s;
  import q::*;
  import p::*;
  e_t sv;
endpackage
module m;
  import s::*;
  import q::*;
  logic [1:0] v = QB;
endmodule
