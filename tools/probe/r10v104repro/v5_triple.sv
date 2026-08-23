// v104 arm V5 - triple-backtick joins at the START, MIDDLE and END of the
// stringification, plus runs of 4/5/6 backticks (where the regex wildcard can
// eat a BACKTICK and destroy a macro reference).
`define TN pqr
`define TA 5
`define TS_START `"```TN``-```TA`"
`define TS_MID   `"x```TN``-```TA``-```TN`"
`define TS_END   `"`TN``-```TA```"
`define TS_B4    `"a````b`"
`define TS_B5    `"a`````b`"
`define TS_B6    `"a``````b`"
package v5_pk;
  parameter string t_start = `TS_START;
  parameter string t_mid   = `TS_MID;
  parameter string t_end   = `TS_END;
  parameter string t_b4    = `TS_B4;
  parameter string t_b5    = `TS_B5;
  parameter string t_b6    = `TS_B6;
endpackage
module v5_top; endmodule
