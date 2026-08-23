// v104 arm V7 - escaped quotes inside the stringification, in every position
// relative to the paste window.
`define EN kk
`define EA 8
`define E1 `"`\`"`EN``-```EA`\`"`"
`define E2 `"`\`"a``-``b`\`"`"
`define E3 `"a``-``b`\`"tail`"
`define E4 `"head`\`"a``-``b`"
package v7_pk;
  parameter string e1 = `E1;
  parameter string e2 = `E2;
  parameter string e3 = `E3;
  parameter string e4 = `E4;
endpackage
module v7_top; endmodule
