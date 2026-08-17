// d1: how far does the LEFT-OPERAND descent go, and what does it harvest?
module d1_earl49 #(
  parameter int           W    = 32,
  parameter logic [W-1:0] D1a  = 'h1,  // (D1a + D1b) & n   -- compound left operand
  parameter logic [W-1:0] D1b  = 'h2,
  parameter logic [W-1:0] D2   = 'h3,  // ~D2 & n           -- unary left operand
  parameter logic [W-1:0] D3   = 'h4,  // {D3, 4'b0} & n    -- concat left operand
  parameter logic [W-1:0] D5   = 'h5,  // D5 & n & m        -- left spine, depth 2
  parameter logic [W-1:0] D6   = 'h6,  // n & D6 & m        -- buried at depth 2
  parameter logic [W-1:0] D9a  = 'h7,  // D9a & n & D9b     -- right operand after a hit
  parameter logic [W-1:0] D9b  = 'h8,
  parameter              [W-1:0] R1 = 'h9,   // ranged UNTYPED, left operand
  parameter              R2 = 31'h7f800000   // untyped SIZED literal, left operand
) (
  input  logic [W-1:0] n, m,
  output logic [W-1:0] o1, o2, o3, o5, o6, o9, oR1, oR2
);
  assign o1  = (D1a + D1b) & n;
  assign o2  = ~D2 & n;
  assign o3  = {D3[3:0], 28'b0} & n;
  assign o5  = D5 & n & m;
  assign o6  = n & D6 & m;
  assign o9  = D9a & n & D9b;
  assign oR1 = R1 & n;
  assign oR2 = R2 & n;
endmodule
