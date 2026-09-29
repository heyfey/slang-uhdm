// § pkgImportEnumCloneLastWriter215 — a package importing an enum VALUE item and a module importing the typedef
package p;
  typedef enum logic [1:0] {A, B} e_t;
endpackage
package q;
  import p::A;
  parameter int QV = 1;
endpackage
module m(output p::e_t o);
  import p::e_t;
  assign o = p::B;
endmodule
