// r10vearl110 arm v5 -- VALUE-SPELLING and LEAF-KIND faces.  The patch renders a
// parameter leaf through selWidthParamFold's text.  Every one of these is a
// place where that text could disagree with what ExprEval::prettyPrint prints
// for the same folded leaf, or where golden might keep the leaf SYMBOLIC at
// depth 1 (which would be an AWAY).
package pv5;
  parameter int unsigned OUTER = 7;
  parameter logic [7:0] BASED = 8'hA;
  typedef struct packed { logic [31:0] fld; } c_t;
endpackage

module v5_value #(parameter int unsigned NCH = 2) (
  input  pv5::c_t chan [NCH],
  output logic [31:0] oz
);
  localparam int unsigned  MA  = 9;
  localparam int           NEG = -2;              // NEGATIVE value
  localparam logic [7:0]   LB  = 8'hA;            // BASED-literal value (10)
  localparam int unsigned  BIG = 1024;            // multi-digit
  localparam int unsigned  DER = MA - 1;          // derived from another localparam
  logic [31:0] d1,d2,d3,d4,d5,d6,d7,d8,d9;

  for (genvar z = 0; z < NCH; z++) begin : blk_v
    // e1  a localparam declared INSIDE the generate block (shadowing depth)
    localparam int unsigned INNER = 4;
    assign d1 = {27'b0, chan[z].fld[0+:(MA-INNER)]};
    // e2  a NEGATIVE-valued localparam leaf
    assign d2 = {21'b0, chan[z].fld[0+:(MA-NEG)]};
    // e3  a BASED-literal-valued localparam leaf
    assign d3 = {31'b0, chan[z].fld[0+:(LB-MA)]};
    // e4  a multi-digit value
    assign d4 = {17'b0, chan[z].fld[0+:(BIG-1009)]};
    // e5  a DERIVED localparam (its own value is an expression)
    assign d5 = {28'b0, chan[z].fld[0+:(DER-4)]};
    // e6  a PACKAGE parameter with a based-literal value
    assign d6 = {26'b0, chan[z].fld[0+:(pv5::BASED-4)]};
    // e7  a package parameter from an outer package
    assign d7 = {28'b0, chan[z].fld[0+:(pv5::OUTER-3)]};
    // e8  MIXED-PRECEDENCE arithmetic, no parens
    assign d8 = {25'b0, chan[z].fld[0+:(MA+INNER*2-11)]};
    // e9  a REDUNDANTLY PARENTHESISED half
    assign d9 = {26'b0, chan[z].fld[0+:((MA)-(3))]};
  end
  assign oz = d1^d2^d3^d4^d5^d6^d7^d8^d9;
endmodule
