// v104 arm V12 - the full separator alphabet the brief names, including the
// ones the implementer did NOT test: '.', ' ', '_', uppercase, '$', '\', '"'.
`define WN nn
`define WA 6
`define W_DOT   `"`WN``.```WA`"
`define W_SPACE `"`WN`` ```WA`"
`define W_UND   `"`WN``_```WA`"
`define W_UPPER `"`WN``Z```WA`"
`define W_DOLLAR `"`WN``$```WA`"
`define W_BANG  `"`WN``!```WA`"
`define W_PCT   `"`WN``%```WA`"
`define W_AMP   `"`WN``&```WA`"
`define W_LT    `"`WN``<```WA`"
`define W_EQ    `"`WN``=```WA`"
`define W_TAB   `"`WN``	```WA`"
package v12_pk;
  parameter string w_dot   = `W_DOT;
  parameter string w_space = `W_SPACE;
  parameter string w_und   = `W_UND;
  parameter string w_upper = `W_UPPER;
  parameter string w_dol   = `W_DOLLAR;
  parameter string w_bang  = `W_BANG;
  parameter string w_pct   = `W_PCT;
  parameter string w_amp   = `W_AMP;
  parameter string w_lt    = `W_LT;
  parameter string w_eq    = `W_EQ;
  parameter string w_tab   = `W_TAB;
endpackage
module v12_top; endmodule
