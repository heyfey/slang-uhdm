// r10oth3 -- the NEW YosysOldOr head, one position BEHIND the one this pass
// cleared.  Filed as residue R1; this arm makes it reproducible in one file.
//
// Corpus witness: or1200_dc_tag.v:99 `assign tag = {dw-1{1'b0}};` with
// `parameter dw = `OR1200_DCTAG_W+1;` = 22 and `output [dw-3:0] tag;` (20 bits).
//   LHS(golden):  constant BIN:000000000000000000000  (21 digits)  vpiSize:20 ct3
//   RHS(ours):    constant BIN:00000000000000000000   (20 digits)  vpiSize:20 ct3
// So golden's DIGIT STRING is the full replication count (dw-1 = 21) while its
// vpiSize is the ASSIGNMENT TARGET width (20); we make both 20, i.e. we clamp
// the digits to the target width.  Both sides agree on vpiSize; only the digit
// string differs, and a constant's value string is a Compare field.
//
// Read with darm.sh + `grep BIN:` on the two dumps.  LHS is ALWAYS golden
// (Surelog); RHS is ALWAYS ours.

// r1 -- the witness shape: replication count is `dw-1`, target NARROWER
module d3_narrow;
parameter dw = 22;
wire [19:0] tag;
assign tag = {dw-1{1'b0}};
endmodule

// r2 -- replication count written as a LITERAL of the same value
module d3_lit;
wire [19:0] tag;
assign tag = {21{1'b0}};
endmodule

// r3 -- replication count EQUAL to the target width
module d3_exact;
parameter dw = 21;
wire [19:0] tag;
assign tag = {dw-1{1'b0}};
endmodule

// r4 -- target WIDER than the replication
module d3_wide;
parameter dw = 22;
wire [31:0] tag;
assign tag = {dw-1{1'b0}};
endmodule

// r5 -- replicated bit is 1'b1, so the digits are distinguishable from padding
module d3_ones;
parameter dw = 22;
wire [19:0] tag;
assign tag = {dw-1{1'b1}};
endmodule
