// r10oth3 TARGET 2 arm d1 -- the YosysOldOr head in miniature.
//
// The bisector (b5_addfiles.sh) cut the trigger from 77 files to THREE:
// or1200_defines.v + or1200_du.v + or1200_top.v.  With those three, golden keeps
// or1200_du's DEF-view port typespec range `[dw-1:0]` UNFOLDED and folds only
// the elaborated instance copy (1 UNFOLDED / 1 FOLDED); we fold BOTH (0 / 2).
// or1200_ic_top with the same three-file treatment is EQUAL on both sides, so the
// trigger is not "a module with a parameter-dependent port range is
// instantiated" on its own.
//
// This file is the smallest shape of it: a Verilog-95 module whose parameter is
// declared AFTER the port list and whose output range reads that parameter,
// instantiated by a parent.  Read with carm.sh + loc113b-style classification;
// each row is a separate module so one run reads several cells.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

// r1 -- instantiated child, parameter declared after the port list (or1200_du's
//       exact spelling), no parameter override
module d1_child(o);
parameter dw = 32;
output [dw-1:0] o;
endmodule

module d1_parent;
wire [31:0] w;
d1_child d1_child(w);
endmodule

// r2 -- same, but NOT instantiated by anybody (so the child is itself a top)
module d1_lone(o);
parameter dw = 32;
output [dw-1:0] o;
endmodule

// r3 -- instantiated child whose parameter is declared in an ANSI header
module d1_ansi #(parameter dw = 32) (output [dw-1:0] o);
endmodule

module d1_ansi_parent;
wire [31:0] w;
d1_ansi d1_ansi(w);
endmodule

// r4 -- instantiated child with an explicit parameter OVERRIDE
module d1_ovr(o);
parameter dw = 32;
output [dw-1:0] o;
endmodule

module d1_ovr_parent;
wire [15:0] w;
d1_ovr #(16) d1_ovr(w);
endmodule

// r5 -- instantiated TWICE, so the def view has two elaborated siblings
module d1_two(o);
parameter dw = 32;
output [dw-1:0] o;
endmodule

module d1_two_parent;
wire [31:0] wa;
wire [31:0] wb;
d1_two ua(wa);
d1_two ub(wb);
endmodule
