// § pkgImpPackedArrElemCopy240: a packed array of a package struct, re-listed in an importing package
package cp;
  typedef struct packed {
    int xd;
    int yd;
  } ps_t;
  parameter ps_t [1:0] allc = {64'd1, 64'd2};
endpackage
package bp;
  import cp::*;
  localparam int W = 4;
endpackage
module top
  import cp::*;
  import bp::*;
 (output logic [W-1:0] o);
  assign o = '0;
endmodule
