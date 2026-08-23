// r10uvm104 arm 1 — the SEPARATOR matrix.  One package parameter per single
// character X placed between two token-paste operators inside a `"..."`
// stringification.  Golden renders EVERY X as '.'.
`define N ABC
`define MA 1
`define MI 2
`define S_DASH   `"`N``-```MA``.```MI```"
`define S_UNDER  `"`N``_```MA``.```MI```"
`define S_DOT    `"`N``.```MA``.```MI```"
`define S_COLON  `"`N``:```MA``.```MI```"
`define S_SLASH  `"`N``/```MA``.```MI```"
`define S_LETTER `"`N``x```MA``.```MI```"
`define S_DIGIT  `"`N``7```MA``.```MI```"
`define S_COMMA  `"`N``,```MA``.```MI```"
`define S_STAR   `"`N``*```MA``.```MI```"
`define S_PLUS   `"`N``+```MA``.```MI```"
`define S_SPACE  `"`N`` ```MA``.```MI```"
`define S_PLAIN  `"`N-`MA.`MI`"
`define S_NOPASTE `"hello world`"
package sep_pk;
  parameter string p_dash   = `S_DASH;
  parameter string p_under  = `S_UNDER;
  parameter string p_dot    = `S_DOT;
  parameter string p_colon  = `S_COLON;
  parameter string p_slash  = `S_SLASH;
  parameter string p_letter = `S_LETTER;
  parameter string p_digit  = `S_DIGIT;
  parameter string p_comma  = `S_COMMA;
  parameter string p_star   = `S_STAR;
  parameter string p_plus   = `S_PLUS;
  parameter string p_space  = `S_SPACE;
  parameter string p_plain  = `S_PLAIN;
  parameter string p_nop    = `S_NOPASTE;
endpackage
module sep_top; endmodule
