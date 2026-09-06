// r10earl110 arm g2 -- THE FENCE.  Every leaf kind and every operator the gate
// admits, and the ones it must REFUSE, side by side in one elaborated scope.
package pk2_110;
  parameter int unsigned PKW = 6;
  typedef struct packed { logic [31:0] fld; } cell_t;
endpackage

module g2_fence110 #(
  parameter  int unsigned OVW = 5,     // OVERRIDABLE -- must NOT fold
  parameter  int unsigned NCH = 2
) (
  input  pk2_110::cell_t chan [NCH],
  output logic [31:0]    ohh
);
  localparam int unsigned LCA = 9;
  localparam int unsigned LCB = 3;
  logic [31:0] f1, f2, f3, f4, f5, f6, f7, f8, f9, fa, fb, fc;
  for (genvar z = 0; z < NCH; z++) begin : blk_z
    // f1 localparam - localparam   -> both leaves fold
    assign f1 = { 24'b0, chan[z].fld[0+:(LCA-LCB)] };
    // f2 localparam + literal
    assign f2 = { 20'b0, chan[z].fld[0+:(LCB+3)] };
    // f3 localparam * literal
    assign f3 = { 26'b0, chan[z].fld[0+:(LCB*2)] };
    // f4 localparam / literal
    assign f4 = { 29'b0, chan[z].fld[0+:(LCA/3)] };
    // f5 PACKAGE parameter - literal
    assign f5 = { 27'b0, chan[z].fld[0+:(pk2_110::PKW-1)] };
    // f6 OVERRIDABLE module parameter - literal  -> must REFUSE (identifier stays)
    assign f6 = { 28'b0, chan[z].fld[0+:(OVW-1)] };
    // f7 THREE-TERM arithmetic (a nested BinaryOp leaf) -> refused by the gate
    assign f7 = { 26'b0, chan[z].fld[0+:(LCA-LCB-1)] };
    // f8 a system call leaf -> refused
    assign f8 = { 30'b0, chan[z].fld[0+:($clog2(NCH)+1)] };
    // f9 a BASED literal beside a parameter -> the literal keeps its spelling
    assign f9 = { 26'b0, chan[z].fld[0+:(LCA-4'd3)] };
    // fa literal - literal, NO parameter -> must be byte-identical
    assign fa = { 26'b0, chan[z].fld[0+:(9-3)] };
    // fb the GENVAR in the base half beside a parameter
    assign fb = { 28'b0, chan[z].fld[(z*LCB)+:4] };
    // fc a MINUS-COLON tail with a param-arith base and a param-arith width
    assign fc = { 26'b0, chan[z].fld[(LCA+2)-:(LCA-LCB)] };
  end
  assign ohh = f1 ^ f2 ^ f3 ^ f4 ^ f5 ^ f6 ^ f7 ^ f8 ^ f9 ^ fa ^ fb ^ fc;
endmodule
