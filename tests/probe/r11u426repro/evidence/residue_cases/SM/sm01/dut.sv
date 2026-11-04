// residue (decoded, not written): the class_typespec of a package struct member in the importer listing copy carries the home package as vpiInstance
package p;
  class C;
  endclass
  typedef struct { C m; string n; } s_t;
endpackage
package q;
  import p::*;
  class D;
    s_t x;
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
