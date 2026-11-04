// § pkgImpPackedArrElemCopy240: a packed union element, a dimension bound by a package localparam
package cp;
  localparam NC = 2;
  typedef union packed {
    logic [31:0] w;
    logic [3:0][7:0] b;
  } pu_t;
  parameter pu_t [NC-1:0] allu = {32'd1, 32'd2};
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
