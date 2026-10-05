// § pkgImpPackedArrElemCopy240: a two-level packed array of a struct re-listed, the module reads a member as a width
package cp;
  typedef struct packed {
    logic [3:0] xd;
    logic [3:0] yd;
  } ps_t;
  parameter ps_t [1:0][1:0] allc = '{'{8'h12, 8'h34}, '{8'h56, 8'h78}};
endpackage
package bp;
  import cp::*;
  localparam int W = allc[0][1].xd;
endpackage
module top
  import cp::*;
  import bp::*;
 (output logic [W-1:0] o);
  assign o = allc[1][0].yd;
endmodule
