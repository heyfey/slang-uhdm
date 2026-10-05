// § pkgImpPackedArrElemCopy240: the module reads the element (member select of a selected element)
package cp;
  localparam max_c = 4;
  typedef struct packed { int xd; int yd; } ps_t;
  parameter ps_t [max_c-1:0] allc = {64'd1, 64'd2, 64'd3, 64'd4};
endpackage
package bp;
  import cp::*;
  localparam int W = 4;
endpackage
module top
  import cp::*;
  import bp::*;
 #(parameter int sel = 1)
 (output logic [W-1:0] o);
  localparam ps_t pp = allc[sel];
  assign o = pp.xd[3:0];
endmodule
