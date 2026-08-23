// v104 arm V3 - `ifdef branches.  Both branches carry a stringification with a
// paste window but DIFFERENT text; only one is taken.  If getFullyOriginalLoc
// lands on the wrong `" the model rewrites the wrong characters.
`define TAKEN
`define BN zz
`define BA 7
`ifdef TAKEN
  `define BR `"`BN``-```BA``+``yes`"
`else
  `define BR `"`BN``-```BA``+``no`"
`endif
`ifndef TAKEN
  `define BS `"`BN``,```BA``,``alpha`"
`else
  `define BS `"`BN``;```BA``;``beta`"
`endif
package v3_pk;
  parameter string b_r = `BR;
  parameter string b_s = `BS;
endpackage
module v3_top; endmodule
