// h4: separating the three carriers that h2/h3 confounded — NET-DECLARATION
// assignment vs plain CONTINUOUS assign, the operator, and the gen_scope.
// Every Kn is read in exactly ONE position and every pair differs in exactly
// one carrier.
module h4_earl50 #(
  parameter int           W  = 32,
  parameter logic [W-1:0] K1 = 'h0,  // CONT-ASSIGN   K1[0] | n1[0]
  parameter logic [W-1:0] K2 = 'h0,  // NET-DECL      K2[0] | n1[0]      (h2.I9)
  parameter logic [W-1:0] K3 = 'h0,  // GEN_SCOPE CA  K3[0] | n1[0]      (h1.H1)
  parameter logic [W-1:0] K4 = 'h0,  // CONT-ASSIGN   {31'b0, K4[0] | n1[0]}  (h1.HG)
  parameter logic [W-1:0] K5 = 'h0,  // NET-DECL      K5[0] ? n1[0] : n2[0]   (h3.J3)
  parameter logic [W-1:0] K6 = 'h0,  // CONT-ASSIGN   K6[0] ? n1[0] : n2[0]   (h2.I2)
  parameter logic [W-1:0] K7 = 'h0,  // GEN_SCOPE CA  K7[0] | n1        (net operand stops the walk)
  parameter logic [W-1:0] K8 = 'h0,  // GEN_SCOPE CA  {31'b0, K8[0] | n1[0]}
  parameter logic [W-1:0] K9 = 'h0,  // CONT-ASSIGN   K9 | {31'b0, n1[0]}     (bare name, c1.C1)
  parameter logic [W-1:0] KA = 'h0,  // NET-DECL      KA                (bare name IS the RHS)
  parameter logic [W-1:0] KB = 'h0   // NET-DECL      KB | {31'b0, n1[0]}     (bare name operand)
) (
  input  logic [W-1:0] n1, n2,
  output logic [W-1:0] o1, o4, o6, o9
);
  assign o1 = K1[0] | n1[0];
  wire   [W-1:0] t2 = K2[0] | n1[0];
  if (W > 0) begin : gen_k3
    wire [W-1:0] t3;
    assign t3 = K3[0] | n1[0];
  end
  assign o4 = {31'b0, K4[0] | n1[0]};
  wire   [W-1:0] t5 = K5[0] ? n1[0] : n2[0];
  assign o6 = K6[0] ? n1[0] : n2[0];
  if (W > 0) begin : gen_k7
    wire [W-1:0] t7;
    assign t7 = K7[0] | n1;
  end
  if (W > 0) begin : gen_k8
    wire [W-1:0] t8;
    assign t8 = {31'b0, K8[0] | n1[0]};
  end
  assign o9 = K9 | {31'b0, n1[0]};
  wire   [W-1:0] ta = KA;
  wire   [W-1:0] tb = KB | {31'b0, n1[0]};
endmodule
