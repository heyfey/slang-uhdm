// r10vearl110 arm v4 -- THE PAIR ARM the task names: THE SAME PATH WRITTEN IN A
// MODULE SCOPE AND IN A GENERATE SCOPE, IN ONE DESIGN, byte for byte identical
// source text.  Golden must keep the module-scope copy SYMBOLIC and fold the
// generate-scope copy; if the patch's scope gate leaks, the module-scope copy
// moves and that is an AWAY on a cell the whole corpus contains.
// Also: 1 vs 2 vs 3 instances of the same module with DIFFERENT parameter
// values, which is what makes the Earlgrey head 40/18/1.
package pv4;
  typedef struct packed { logic [31:0] fld; } c_t;
endpackage

module v4_leaf #(parameter int unsigned NCH = 2) (
  input  pv4::c_t chan [NCH],
  output logic [31:0] oy
);
  localparam int unsigned QA = 8;
  localparam int unsigned QB = $clog2(NCH);   // DIFFERS per instance: 1, 2, 2
  logic [31:0] m1, m2, m3;

  // THE MODULE-SCOPE COPY -- identical source text to the gen-scope one below
  assign m1 = {24'b0, chan[0].fld[0+:(QA-QB)]};
  assign m2 = {28'b0, chan[0].fld[(QA-1)-:QB]};

  // THE GENERATE-SCOPE COPY at depth 1
  for (genvar z = 0; z < NCH; z++) begin : pair_blk
    assign m3 = {24'b0, chan[z].fld[0+:(QA-QB)]} ^ {28'b0, chan[z].fld[(QA-1)-:QB]};
  end
  assign oy = m1 ^ m2 ^ m3;
endmodule

module v4_pair (output logic [31:0] oz);
  pv4::c_t b2 [2];
  pv4::c_t b3 [3];
  pv4::c_t b4 [4];
  logic [31:0] r2, r3, r4;
  v4_leaf #(.NCH(2)) u2 (.chan(b2), .oy(r2));   // QB = 1
  v4_leaf #(.NCH(3)) u3 (.chan(b3), .oy(r3));   // QB = 2
  v4_leaf #(.NCH(4)) u4 (.chan(b4), .oy(r4));   // QB = 2
  assign oz = r2 ^ r3 ^ r4;
endmodule
