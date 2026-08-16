// q8 — a class data-member queue whose element type is declared in the PACKAGE,
// not in the class.  Separates "the TYPE's home" from "the DECLARATION's home":
// if golden keys on the type's scope, this cell keeps the stamp.
package p8;
  typedef struct { int a; } s8_t;
  class c8;
    s8_t q8[$];
  endclass
endpackage
module top8;
  p8::c8 h8;
  initial h8 = new();
endmodule
