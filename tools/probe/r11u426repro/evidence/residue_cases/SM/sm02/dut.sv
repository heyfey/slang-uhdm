// residue (decoded, not written): the class_typespec of a package struct member in the importer listing copy carries the home package as vpiInstance
package p;
  class C;
  endclass
  typedef struct { C m; string n; } s_t;
endpackage
module top;
  import p::*;
  s_t x;
endmodule
