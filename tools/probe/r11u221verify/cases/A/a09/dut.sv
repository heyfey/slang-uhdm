// § pkgImportEnumCloneLastWriter215 — a plain enum imported by three packages and a program, an interface and a module, name order against source order
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
package zz; import p::*; e_t z; endpackage
package aa; import p::*; e_t a; endpackage
package mm; import p::*; e_t m; endpackage
program pg; import p::*; e_t g; endprogram
interface bi; import p::*; e_t b; endinterface
module top; import p::*; e_t t; bi u(); pg v(); endmodule
