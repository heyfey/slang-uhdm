// v104 arm V4 - nested macros 1..3 deep, including a stringification reached
// only through another macro (so the literal's original location is two hops
// away) and macro references inside the stringification that are themselves
// nested.
`define L1 aa
`define L2 `L1
`define L3 `L2
`define D1 `"`L1``-```L1`"
`define D2 `"`L2``-```L2`"
`define D3 `"`L3``-```L3`"
`define OUT1 `D1
`define OUT2 `OUT1
`define OUT3 `OUT2
package v4_pk;
  parameter string n1 = `D1;
  parameter string n2 = `D2;
  parameter string n3 = `D3;
  parameter string o1 = `OUT1;
  parameter string o2 = `OUT2;
  parameter string o3 = `OUT3;
endpackage
module v4_top; endmodule
