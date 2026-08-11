// r10oth3 TARGET 2 arm d2 -- the DISTINGUISHER between or1200_du (defect) and
// or1200_ic_top (equal).
//
// or1200_du.v declares `spr_dat_o` TWICE, Verilog-95 style:
//     line 113:  output [dw-1:0]  spr_dat_o;     <- the head's range, reads dw
//     line 450:  reg    [31:0]    spr_dat_o;     <- the variable, literal range
// or1200_ic_top.v's `icqmem_dat_o` has NO second declaration, and or1200_ic_top
// is EQUAL on both sides in the same 3-file compile.  Arm d1 (a plain
// instantiated child with `output [dw-1:0] o;` and nothing else) is EQUAL too,
// in all five of its spellings.  So the candidate predicate is the SPLIT
// PORT/VARIABLE DECLARATION.
//
// Every row is one module pair.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS
// ours.  Read with darm.sh.

// r1 -- or1200_du's exact shape: split decl, reg range is a LITERAL, instantiated
module d2_child(o);
parameter dw = 32;
output [dw-1:0] o;
reg [31:0] o;
always @(*) o = 32'd0;
endmodule

module d2_parent;
wire [31:0] w;
d2_child d2_child(w);
endmodule

// r2 -- same but NOT instantiated (the child is its own top)
module d2_lone(o);
parameter dw = 32;
output [dw-1:0] o;
reg [31:0] o;
always @(*) o = 32'd0;
endmodule

// r3 -- split decl where the reg range ALSO reads the parameter
module d2_par(o);
parameter dw = 32;
output [dw-1:0] o;
reg [dw-1:0] o;
always @(*) o = 32'd0;
endmodule

module d2_par_parent;
wire [31:0] w;
d2_par d2_par(w);
endmodule

// r4 -- split decl with a WIRE instead of a reg
module d2_wire(o);
parameter dw = 32;
output [dw-1:0] o;
wire [31:0] o;
assign o = 32'd0;
endmodule

module d2_wire_parent;
wire [31:0] w;
d2_wire d2_wire(w);
endmodule

// r5 -- split decl, reg declared WITHOUT a range at all.  REMOVED: slang rejects
//       it outright ("inconsistent dimensions declared for 'o'"), so the cell is
//       not measurable on our side and would have made the whole arm NO_OUTPUT.
//       Recorded rather than silently dropped.

// r6 -- CONTROL: no split declaration, instantiated (arm d1 r1 repeated here so
//       the equal and unequal cells are in ONE database and one run)
module d2_ctl(o);
parameter dw = 32;
output [dw-1:0] o;
endmodule

module d2_ctl_parent;
wire [31:0] w;
d2_ctl d2_ctl(w);
endmodule
