// VERIFIER CELL v2: a PACKED array member (packed_array_typespec arm).
package p8;
  typedef logic [3:0] n8;
  n8 m8 [string];
endpackage

package q8;
  import p8::*;
  class c8;
    int own8;
  endclass
endpackage

module top8;
  q8::c8 h8;
endmodule
