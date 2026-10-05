// § pkgImpPackedArrElemCopy240: controls: an unpacked array of the struct, a struct parameter, a vector typedef element
package cp;
  typedef struct packed { int xd; int yd; } ps_t;
  typedef logic [3:0] nib_t;
  parameter ps_t ua [2] = '{64'd1, 64'd2};
  parameter ps_t one = 64'd3;
  parameter nib_t [1:0] nibs = 8'h21;
endpackage
package bp;
  import cp::*;
  localparam int W = 4;
endpackage
module top
  import cp::*;
  import bp::*;
 (output logic [W-1:0] o);
  assign o = nibs[0];
endmodule
