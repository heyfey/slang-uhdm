// r11v50 BREAK grid b5 — the OTHER substitution SITES the law's helper feeds
// (§ patDefBoundPkgParamSubst named-element arrays, § shadowedImportBoundFold,
// a generate-block bound, a function-body bound) and a DEEP derivation chain,
// all on the multiply the marker never marked.
package s55;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } el_t;
  parameter int unsigned A = 16;
  parameter int unsigned B = 2;
  parameter int unsigned NM  = A * B;      // 32, a MULTIPLY
  parameter int unsigned NA  = A + B;      // 18, a plain ADD (control)
  parameter int unsigned NS  = A - B;      // 14, a top-level SUBTRACT (marker fires)
  // a nine-hop derivation chain ending in a multiply
  parameter int unsigned H1 = A * B;
  parameter int unsigned H2 = H1;
  parameter int unsigned H3 = H2;
  parameter int unsigned H4 = H3;
  parameter int unsigned H5 = H4;
  parameter int unsigned H6 = H5;
  parameter int unsigned H7 = H6;
  parameter int unsigned H8 = H7;
  parameter int unsigned H9 = H8;
endpackage

module m55 import s55::*; (input logic clk);
  el_t  [NM-1:0] c01;               // f01 NAMED-ELEMENT packed array, multiply
  el_t  [NA-1:0] c02;               // f02 named element, plain add (control)
  el_t  [NS-1:0] c03;               // f03 named element, top-level subtract
  logic [H9-1:0] c04;               // f04 a NINE-HOP chain to a multiply
  logic [NM-1:0] c05;               // f05 the plain-vector control
  for (genvar gi = 0; gi < 2; gi++) begin : gblk
    logic [NM-1:0] c06;             // f06 inside a GENERATE block
  end
  function automatic int unsigned f55();
    logic [NM-1:0] c07;             // f07 inside a FUNCTION body
    f55 = 1;
  endfunction
endmodule

// § shadowedImportBoundFold: a MODULE-LOCAL parameter of the same name does not
// hide the wildcard-imported one from Surelog's name-keyed getValue.
module m56 import s55::*; (input logic clk);
  localparam int unsigned NM = 7;
  logic [NM-1:0] c08;               // f08 the SHADOWED name
endmodule

module tb55;
  logic clk;
  m55 u5 (.clk(clk));
  m56 u6 (.clk(clk));
endmodule
