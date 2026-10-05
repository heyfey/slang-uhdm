// § pkgImpPackedArrElemCopy240: the importing package overrides nothing but declares a parameter of the same struct type built from the imported array
package cp;
  typedef struct packed {
    logic [3:0] xd;
    logic [3:0] yd;
  } ps_t;
  parameter ps_t [1:0] allc = 16'h1234;
endpackage
package bp;
  import cp::*;
  parameter ps_t pick = allc[1];
  parameter ps_t [1:0] mine = allc;
endpackage
module top
  import bp::*;
 (output logic [3:0] o);
  assign o = pick.yd ^ mine[0].xd;
endmodule
