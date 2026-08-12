// r10earl31 arm e2 — THE ORIGIN AXIS, position held at the witness's (a
// part-select range bound inside a process).  What KIND of fold does golden hang
// a typespec on, and WHAT does the typespec point at?
//
// cells, by the line of the folded constant:
//   c1  pk::DC     package localparam, `logic [3:0]`   (the witness's origin)
//   c2  pk::IC     package localparam, `int`
//   c3  pk::UC     package localparam, IMPLICIT type (`localparam UC = 3;`)
//   c4  pk::SC     package localparam, `logic signed [3:0]`
//   c5  pk::TC     package localparam of a TYPEDEF'd type
//   c6  pk::E2     package ENUM literal
//   c7  ML         MODULE localparam        — the negative control
//   c8  MP         MODULE parameter         — the negative control
//   c9  FL         FUNCTION-local localparam
//   c10 pk::DC     read UNQUALIFIED through `import pk::*` (module e2i)
//   c11 pk::DC     read QUALIFIED in a module that ALSO imports pk (module e2i)
//   c12 4'h2       a plain sized LITERAL bound — must never be stamped
package pk;
  typedef logic [3:0] w_t;
  localparam logic [3:0]        DC = 4'h2;
  localparam int                IC = 3;
  localparam                    UC = 3;
  localparam logic signed [3:0] SC = 4'h3;
  localparam w_t                TC = 4'h3;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
endpackage

module e2 (
  input  logic [31:0] d,
  output logic [31:0] y
);
  localparam logic [3:0] ML = 4'h2;
  parameter  logic [3:0] MP = 4'h2;
  logic [31:0] a1, a2, a3, a4, a5, a6, a7, a8, a9, ab;

  always_comb begin : blk
    a1 = 32'(d[pk::DC-1:0]);      // c1
    a2 = 32'(d[pk::IC-1:0]);      // c2
    a3 = 32'(d[pk::UC-1:0]);      // c3
    a4 = 32'(d[pk::SC-1:0]);      // c4
    a5 = 32'(d[pk::TC-1:0]);      // c5
    a6 = 32'(d[pk::E2-1:0]);      // c6
    a7 = 32'(d[ML-1:0]);          // c7
    a8 = 32'(d[MP-1:0]);          // c8
    ab = 32'(d[4'h2-1:0]);        // c12
  end

  function automatic [31:0] f2(input logic [31:0] w);
    localparam logic [3:0] FL = 4'h2;
    f2 = 32'(w[FL-1:0]);          // c9
  endfunction

  assign a9 = f2(d);
  assign y = a1 ^ a2 ^ a3 ^ a4 ^ a5 ^ a6 ^ a7 ^ a8 ^ a9 ^ ab;
endmodule

module e2i (
  input  logic [31:0] d,
  output logic [31:0] y
);
  import pk::*;
  logic [31:0] b1, b2;
  always_comb begin : blk
    b1 = 32'(d[DC-1:0]);          // c10  unqualified, materialized import
    b2 = 32'(d[pk::DC-1:0]);      // c11  qualified, import ALSO present
  end
  assign y = b1 ^ b2;
endmodule
