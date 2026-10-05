// § pkgImpPackedArrElemCopy240: the element is an alias of a struct typedef, imported by name, not by wildcard
package cp;
  typedef struct packed {
    int xd;
    int yd;
  } ps_t;
  typedef ps_t alias_t;
  parameter alias_t [1:0] allc = {64'd1, 64'd2};
endpackage
package bp;
  import cp::allc;
  localparam int W = 4;
endpackage
module top
  import cp::*;
  import bp::*;
 (output logic [W-1:0] o);
  assign o = '0;
endmodule
