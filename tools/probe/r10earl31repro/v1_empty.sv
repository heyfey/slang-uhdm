// r10earl31 VERIFIER arm v1 — THE EMPTY PRODUCT CELLS the implementer's grid
// skips.  Origin held at the witness's (a QUALIFIED read of a package localparam
// in a module that does not import the package); what varies is the POSITION /
// CONTEXT the part_select itself sits in, which is the axis § psBoundPkgParamTs31
// claims universally ("every scope, either bound, any spelling") and which
// e1/e3/e4 sample only on RHS reads in plain processes.
//
//   v1  lhs1[pk::DC-1:0] = ...     part_select as an ASSIGNMENT TARGET (LHS)
//   v2  mem[2][pk::DC-1:0]         part_select of an UNPACKED-ARRAY ELEMENT
//   v3  {>>{d[pk::DC-1:0]}}        part_select inside a STREAMING concat
//   v4  d[pk::DC+pk::DC:0]         TWO folds in ONE bound
//   v5  lhs2[pk::DC-1:0] <= ...    LHS part_select, NONBLOCKING, always_ff
//   v6  d[pk::PP-1:0]              a package `parameter` (not localparam) origin
//   v7  inside a TASK body         the subroutine axis, task flavour
//   v8  .a(32'(d[pk::DC-1:0]))     a PORT-CONNECTION actual (def + elab views)
//   v9  ii.s[pk::DC-1:0]           hier_path over an INTERFACE INSTANCE
//   v10 generate-IF scope          (e4 k6 has generate-FOR only)
//   v11 module v1i: import pk::DC  an EXPLICIT single-item import (e2 c10 is
//                                  wildcard-only)
//   v12 class method body          (§ pkgParamInClassMethodStaysRef47's axis)
package pk;
  localparam logic [3:0] DC = 4'h2;
  parameter  logic [3:0] PP = 4'h3;
  typedef struct packed {
    logic [6:0]  addr;
    logic [31:0] data;
  } req_t;
endpackage

interface if1;
  logic [31:0] s;
endinterface

module v1sub (input logic [31:0] a, output logic [31:0] b);
  assign b = a;
endmodule

module v1 (
  input  logic [31:0] d,
  input  logic        clk,
  input  pk::req_t    r,
  output logic [31:0] y
);
  logic [31:0] w1, w2, w3, w4, w5, w6, w7, w8;
  logic [31:0] lhs1, lhs2;
  logic [31:0] mem [0:3];

  always_comb begin : blk
    lhs1 = 32'b0;
    lhs1[pk::DC-1:0] = d[3:0];             // v1  LHS part-select bound
    w1 = 32'(mem[2][pk::DC-1:0]);          // v2  unpacked-array element select
    w2 = {>>{d[pk::DC-1:0]}};              // v3  streaming concat operand
    w3 = 32'(d[pk::DC+pk::DC:0]);          // v4  two folds in one bound
  end

  always_ff @(posedge clk) begin
    lhs2[pk::DC-1:0] <= d[3:0];            // v5  LHS, nonblocking
  end

  always_comb w4 = 32'(d[pk::PP-1:0]);     // v6  package `parameter` origin

  task automatic t1(input logic [31:0] z); // v7  task body
    w5 = 32'(z[pk::DC-1:0]);
  endtask
  always_comb begin
    t1(d);
  end

  v1sub u1 (.a(32'(d[pk::DC-1:0])), .b(w6)); // v8 port-connection actual

  if1 ii ();
  always_comb w7 = 32'(ii.s[pk::DC-1:0]);  // v9  hier_path over an interface

  if (1) begin : gi                        // v10 generate-IF scope
    always_comb w8 = 32'(d[pk::DC-1:0]);
  end

  assign y = w1 ^ w2 ^ w3 ^ w4 ^ w5 ^ w6 ^ w7 ^ w8 ^ lhs1 ^ lhs2 ^ 32'(r.addr);
endmodule

module v1i (
  input  logic [31:0] d,
  output logic [31:0] y
);
  import pk::DC;                           // v11 EXPLICIT single-item import
  logic [31:0] b1;
  always_comb begin : blk
    b1 = 32'(d[DC-1:0]);
  end
  assign y = b1;
endmodule

module v1c (
  input  logic [31:0] d,
  output logic [31:0] y
);
  class cc;                                // v12 class method body
    function automatic logic [31:0] f(logic [31:0] z);
      return 32'(z[pk::DC-1:0]);
    endfunction
  endclass
  logic [31:0] c1;
  always_comb begin : blk
    c1 = 32'(d[pk::DC-1:0]);
  end
  assign y = c1;
endmodule
