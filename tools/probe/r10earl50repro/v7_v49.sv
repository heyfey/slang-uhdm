// v7 (VERIFIER) — the CLASSIFIER RESIDUE ENUMERATION.  Every cell puts an
// operand kind that `srlgClassify49` sends down its conservative `Stop` exit at
// operand0 of a CONCAT (a top-level operation whose operands are walked in
// source order), and a plain parameter at operand1 as the REPORTER.  Golden
// BARE on the reporter means UHDM STEPPED OVER the probe and we did not -- a
// MISS.  Golden LOCATED means our Stop exit is right.
//
// v5 could not measure this: `16'(K2) & K1 & n` parses as `((16'(K2)&K1)&n)`,
// so the cast is never at the TOP-LEVEL operand0 and the trailing net stops the
// walk before anything is decided.
package v7p;
  typedef struct packed { logic [15:0] a; logic [15:0] b; } v7s_t;
  parameter v7s_t SP = '{a: 16'h1, b: 16'h2};
endpackage

module v7_sub #(parameter logic [31:0] Q = 32'h0) (output logic [31:0] y);
  assign y = Q;
endmodule

module v7_v49 #(
  parameter int           W  = 32,
  parameter logic [W-1:0] M1 = 32'h1,  // {16'(M1x), M1, n} -- CAST probe
  parameter logic [W-1:0] M1x= 32'h9,
  parameter logic [W-1:0] M2 = 32'h2,  // {~M2x, M2, n}     -- UNARY probe
  parameter logic [W-1:0] M2x= 32'h8,
  parameter logic [W-1:0] M3 = 32'h3,  // {SP.a, M3, n}     -- MEMBER probe
  parameter logic [W-1:0] M4 = 32'h4,  // {M4x[3:0], M4, n} -- PART-SELECT probe
  parameter logic [W-1:0] M4x= 32'h7,
  parameter logic [W-1:0] M5 = 32'h5,  // {M5x[2], M5, n}   -- BIT-SELECT probe
  parameter logic [W-1:0] M5x= 32'h6,
  parameter logic [W-1:0] M6 = 32'hc   // {u_s.Q, M6, n}    -- HIER-PATH probe
) (
  input  logic [W-1:0] n,
  output logic [95:0]  s1, s2, s3, s6,
  output logic [79:0]  s4,
  output logic [64:0]  s5,
  output logic [31:0]  yy
);
  assign s1 = {16'(M1x), M1, n};
  assign s2 = {~M2x, M2, n};
  assign s3 = {v7p::SP.a, M3, n};
  assign s4 = {M4x[15:0], M4, n};
  assign s5 = {M5x[2], M5, n};
  assign s6 = {u_s.Q, M6, n};
  v7_sub #(.Q(32'hd)) u_s (.y(yy));
endmodule
