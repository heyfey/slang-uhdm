// § assocPromotedBoundAtBracket183 (a class property keyed by a typedef, in a package; two dimensions)
package p;
  typedef int unsigned id_t;
  class c;
    bit m[id_t];
    int n[id_t][string];
  endclass
endpackage
module top; endmodule
