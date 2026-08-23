// v104 arm V13 - macro WITH ARGUMENTS whose paste window does NOT touch a
// formal, vs one that does; and a formal referenced with a backtick.
`define TAG(x) `"pre``-``post_``x`"
`define TAG2(x) `"``-``x`"
`define TAG3(x) `"x``-``tail`"
`define TAG4(x) `"lead``-``x``-``tail`"
`define TAG5(x,y) `"`x``-```y`"
`define x_ XV
`define y_ YV
package v13_pk;
  parameter string g1 = `TAG(zz);
  parameter string g2 = `TAG2(zz);
  parameter string g3 = `TAG3(zz);
  parameter string g4 = `TAG4(zz);
  parameter string g5 = `TAG(x);
  parameter string g6 = `TAG3(x);
endpackage
module v13_top; endmodule
