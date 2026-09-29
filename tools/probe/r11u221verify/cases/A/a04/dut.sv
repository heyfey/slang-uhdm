// § enumCloneValueItemKeepsBare215v + § pkgImportEnumCloneLastWriter215 — explicit-item imports of an enum VALUE into a module, an interface and a package; a wildcard import in a later package
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
package q;
  import p::B;
  parameter logic [1:0] QB = B;
endpackage
package r;
  import p::*;
  e_t rv;
endpackage
interface ifc;
  import p::C;
  logic [1:0] s = C;
endinterface
module m;
  import p::A;
  logic [1:0] v = A;
  ifc u();
endmodule
