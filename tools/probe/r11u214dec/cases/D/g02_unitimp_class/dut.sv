// § unitImportCopyOwnTsRef214 — a $unit import hoists package parameters into the design listing, a $unit class inherits them (SimpleUVM's / Scoreboard's UVM_MACRO_NUMFLAGS shape: the package's own param_assign reads a hoisted copy)
package p;
  parameter NUMFLAGS = 4;
  parameter EXTRAS = 1 << NUMFLAGS;
  parameter W = 120;
  parameter L = W*8-1;
endpackage
import p::*;
class sb;
  int x;
endclass
module top(output int o);
  assign o = 0;
endmodule
