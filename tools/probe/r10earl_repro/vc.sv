// r10earl10 witness: PARENTHESES inside a DEF-VIEW hier_path SELECT.
// tlul_socket_m1.sv:97 `tl_h_i[i].a_source[0+:(IDW-STIDW)]` — golden's
// hier_path VpiName reads `...[0+:IDW - STIDW]`, ours `...[0+:(IDW - STIDW)]`.
// Rows build the matrix over where the parens sit.
package vcp;
  typedef struct packed {
    logic [31:0] f;
    logic [7:0]  g;
  } vc_t;
endpackage

module vc #(
  parameter int A = 8,
  parameter int B = 3,
  parameter int M = 2
) (
  input  vcp::vc_t [1:0] in_i,
  output logic [31:0]    o
);
  localparam int C = A - B;

  for (genvar i = 0; i < M; i++) begin : gen_p
    logic [A-B-1:0] w1;
    logic [A-B-1:0] w2;
    logic [A-B-1:0] w3;
    logic [1:0]     w4;
    logic [A-1:0]   w5;
    logic [A-1:0]   w6;
    logic [A-1:0]   w7;
    // 1: parens around the indexed-part-select WIDTH
    assign w1 = in_i[i].f[0+:(A-B)];
    // 2: same width, NO parens (control)
    assign w2 = in_i[i].f[0+:A-B];
    // 3: parens around the BASE of the indexed part select
    assign w3 = in_i[i].f[(B-B)+:C];
    // 4: parens inside a plain [L:R] part select
    assign w4 = in_i[i].f[(B-1):0];
    // 5: parens inside a bit select
    assign w5 = {in_i[i].g[(B-1)], 7'b0};
    // 6: WHITESPACE around the `-:` operator (tlul_socket_m1.sv:105)
    assign w6 = in_i[i].f[A-1 -: B];
    // 7: whitespace around `+:` too
    assign w7 = in_i[i].f[0 +: B];
    assign o  = 32'h0;
  end
endmodule
