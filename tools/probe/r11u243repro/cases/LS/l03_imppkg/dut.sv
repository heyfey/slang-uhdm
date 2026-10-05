// § clsPropLawSAliasName243
// a property of a class in an importing package and a rand property
package p;
  typedef logic [3:0] n_t;
endpackage
package q;
  import p::*;
  class c;
    rand n_t r;
    n_t m;
  endclass
endpackage
module top;
  import q::*;
  c o;
endmodule
