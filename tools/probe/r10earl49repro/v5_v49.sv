// v5 (VERIFIER) — residue R3 (explicit CAST operands take the classifier's
// conservative Stop exit where UHDM steps over a vpiCastOp) measured on the shape
// the implementer says no corpus row exhibits, plus struct-member and
// hierarchical operands, and the ternary fence's UNTAKEN branch.
package v5p;
  typedef struct packed { logic [15:0] a; logic [15:0] b; } v5s_t;
  parameter v5s_t SP = '{a: 16'h1, b: 16'h2};
endpackage

module v5_sub #(parameter logic [31:0] SS = 32'h0) (output logic [31:0] y);
  assign y = SS;
endmodule

module v5_v49 #(
  parameter int           W  = 32,
  parameter logic [W-1:0] K1 = 32'h1,  // 16'(K2) & K1 & n  -- CAST operand first
  parameter logic [W-1:0] K2 = 32'h2,
  parameter logic [W-1:0] K3 = 32'h3,  // K3 & 16'(K4) & n  -- CAST operand second
  parameter logic [W-1:0] K4 = 32'h4,
  parameter logic [W-1:0] K5 = 32'h5,  // SP.a & K5 & n     -- MEMBER-ACCESS first
  parameter logic [W-1:0] K6 = 32'h6,  // 1'b1 ? K6 : K7    -- TAKEN branch
  parameter logic [W-1:0] K7 = 32'h7,  // ...               -- UNTAKEN branch
  parameter logic [W-1:0] K8 = 32'h8,  // 1'b0 ? K8 : K9    -- UNTAKEN branch
  parameter logic [W-1:0] K9 = 32'h9   // ...               -- TAKEN branch
) (
  input  logic [W-1:0] n,
  output logic [W-1:0] p1, p3, p5, p6, p8, p9
);
  assign p1 = 16'(K2) & K1 & n;
  assign p3 = K3 & 16'(K4) & n;
  assign p5 = {16'b0, v5p::SP.a} & K5 & n;
  assign p6 = (1'b1 ? K6 : K7) | n;
  assign p8 = (1'b0 ? K8 : K9) | n;
  v5_sub #(.SS(32'h0)) u_s (.y(p9));
endmodule
