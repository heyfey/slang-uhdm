// r10uvm104 arm 2 — the SHAPE matrix.  Paste COUNT, paste POSITION and the
// number of characters between the two pastes decide whether the Surelog
// regex matches at all.
`define Q ABC
`define R 1
`define T 2
`define H0  `"`Q-`R.`T`"
`define H1a `"`Q``-`R`"
`define H1b `"`Q``-``R`"
`define H1c `"pre``-``post`"
`define H2a `"`Q``--```R`"
`define H2b `"`Q``ab```R`"
`define H4a `"``-`Q`"
`define H4b `"`Q-``    `"
`define H5a `"`Q``-```R``.```T``-```Q```"
`define H6a `"`Q``-`R``.`T`"
`define H7a `"xx``-``yy`"
`define H8a `"q`\`"`Q``-```R`\`"z`"
package shape_pk;
  parameter string h0  = `H0;
  parameter string h1a = `H1a;
  parameter string h1b = `H1b;
  parameter string h1c = `H1c;
  parameter string h2a = `H2a;
  parameter string h2b = `H2b;
  parameter string h4a = `H4a;
  parameter string h4b = `H4b;
  parameter string h5a = `H5a;
  parameter string h6a = `H6a;
  parameter string h7a = `H7a;
  parameter string h8a = `H8a;
endpackage
module shape_top; endmodule
