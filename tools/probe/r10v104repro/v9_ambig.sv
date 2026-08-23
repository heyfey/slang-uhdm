// v104 arm V9 - ALIGNMENT AMBIGUITY: macro expansions that themselves contain
// the separator character, so the left-to-right and right-to-left anchors can
// land differently (or, worse, agree on the WRONG position).
`define AX x-
`define AY -y
`define AZ ab
`define M1 `"`AX``-```AZ`"
`define M2 `"`AZ``-```AY`"
`define M3 `"`AX``-```AY`"
`define M4 `"`AZ``-```AZ``-```AZ`"
`define M5 `"aa``-``aa``-``aa`"
`define M6 `"`AZ``a```AZ`"
package v9_pk;
  parameter string m1 = `M1;
  parameter string m2 = `M2;
  parameter string m3 = `M3;
  parameter string m4 = `M4;
  parameter string m5 = `M5;
  parameter string m6 = `M6;
endpackage
module v9_top; endmodule
