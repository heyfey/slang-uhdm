// e1: the cells where the OPERAND-SCAN model and the existing
// caTernOperandRead1 model DISAGREE, plus the operand-kind axis.
module e1_earl49 #(
  parameter int           W   = 32,
  parameter logic [W-1:0] E1  = 'h1,  // (n|m) ? E1 : n     -- param branch, net sibling
  parameter logic [W-1:0] E2  = 'h2,  // (n|m) ? n : E2     -- net branch first
  parameter logic [W-1:0] E3a = 'h3,  // (n|m) ? E3a : E3b  -- both branches params
  parameter logic [W-1:0] E3b = 'h4,
  parameter logic [W-1:0] E4  = 'h5,  // cn ? E4 : E4b      -- BARE-NET condition
  parameter logic [W-1:0] E4b = 'h6,
  parameter logic [W-1:0] E5  = 'h7,  // E5 ? n : m         -- param condition
  parameter logic [W-1:0] E6  = 'h8,  // $clog2(E6) & n     -- sys-func-call operand first
  parameter logic [W-1:0] E7  = 'h9,  // E7[3:0] & n        -- bit/part-select operand first
  parameter logic [W-1:0] E8  = 'ha,  // 32'h1 & E8         -- constant operand first
  parameter logic [W-1:0] E9  = 'hb   // n[0] ? E9 : E9b    -- select condition
) (
  input  logic         cn,
  input  logic [W-1:0] n, m,
  output logic [W-1:0] oe1, oe2, oe3, oe4, oe5, oe6, oe7, oe8, oe9
);
  assign oe1 = (n | m) ? E1 : n;
  assign oe2 = (n | m) ? n : E2;
  assign oe3 = (n | m) ? E3a : E3b;
  assign oe4 = cn ? E4 : E4b;
  assign oe5 = E5 ? n : m;
  assign oe6 = $clog2(E6) & n;
  assign oe7 = E7[3:0] & n;
  assign oe8 = 32'h1 & E8;
  assign oe9 = n[0] ? E9 : m;
endmodule
