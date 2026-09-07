// r10v200 break arm 4 — EVERY Rhs FACE of a param_assign a clone can carry:
// literal, folded expression, string, typed int, real, a localparam, a
// parameter of a THIRD package, and an enum constant.  A copy golden KEEPS an
// Rhs on MUST KEEP it.
package pv4o;
  parameter WOTH = 12;
endpackage

package pv4;
  import pv4o::*;
  parameter        PLIT = 7;
  parameter        PFLD = 4*2-1;
  parameter string PSTR = "abc";
  parameter int    PINT = 9;
  parameter real   PRL  = 1.5;
  localparam       PLOC = 6;
  typedef enum logic [3:0] { EA = 2, EB = 3 } ev4_t;
  function logic [PLIT:0] h1(input logic [PLIT:0] a); h1 = a; endfunction
  function logic [PFLD:0] h2(input logic [PFLD:0] a); h2 = a; endfunction
  function logic [PINT:0] h3(input logic [PINT:0] a); h3 = a; endfunction
  function logic [PLOC:0] h4(input logic [PLOC:0] a); h4 = a; endfunction
  function logic [EB:0]   h5(input logic [EB:0] a);   h5 = a; endfunction
  function logic [WOTH:0] h6(input logic [WOTH:0] a); h6 = a; endfunction
  function string h7(input string s); h7 = {s, PSTR}; endfunction
  function real   h8(input real r);   h8 = r + PRL;   endfunction
endpackage

package pv4imp;
  import pv4::*;
endpackage

module topv4;
  import pv4::*;
  initial $display(PLIT, PSTR, PRL);
endmodule
