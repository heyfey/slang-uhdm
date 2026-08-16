// VERIFIER CELL v1: element type is a TYPEDEF of a CLASS in the source package.
// g6 showed "typedef struct" keeps ALL:<importing pkg>; g1 showed "bare class"
// goes null.  This separates TYPEDEF-ness from STRUCT-ness.
package pa;
  class ka;
    int xa;
  endclass
  typedef ka ta;
  ta ma [string];
endpackage
package qa;
  import pa::*;
  class ca;
    int owna;
  endclass
endpackage
module topa;
  qa::ca ha;
endmodule
