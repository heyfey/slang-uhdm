// r10earl118 VERIFIER arm v1_castform -- CAST FORMS whose Surelog `operation`
// may carry NO Typespec, so `writeCont_assign`'s :2218 clone leg never runs and
// GOLDEN KEEPS THE BINDING.  Every row is a generate-scope own-local whole-name
// target, i.e. exactly the shape r10earl118 suppresses.
// MEASUREMENT ONLY.  Legal SystemVerilog; scored against the GOLDEN database.
module v1_castform #(parameter int PW = 8) (
  input  logic [7:0]        din,
  input  logic signed [7:0] sdin,
  input  logic              c,
  output logic [31:0]       dout
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } sp_t;
  typedef enum logic [7:0] { X_A = 8'h1, X_B = 8'h2 } en_t;

  for (genvar k = 0; k < 2; k++) begin : vb
    logic signed [7:0] c1;  assign c1  = signed'(din);            // sign cast alone
    logic [7:0] c2;         assign c2  = unsigned'(sdin);         // unsigned cast alone
    logic [7:0] c3;         assign c3  = PW'(din);                // PARAMETER-width cast
    sp_t        c4;         assign c4  = sp_t'(din);              // packed-STRUCT cast
    en_t        c5;         assign c5  = en_t'(din);              // ENUM cast
    logic [7:0] c6;         assign c6  = 8'(4'hA);                // cast that FOLDS
    logic [7:0] c7;         assign c7  = 8'(din);                 // cast of a bare ref
    logic [7:0] c8;         assign c8  = 8'($signed(din));         // signed-sysfunc cast operand
    logic [7:0] c9;         assign c9  = c ? 8'(din) : 8'h00;     // cast UNDER a ternary
    logic [7:0] c10;        assign c10 = 8'(din) ^ 8'h0f;         // cast as an OPERAND
    logic       c11;        assign c11 = 1'(din);                 // 1-bit cast
    logic [7:0] c12;        assign c12 = 8'(din[3:0]);            // cast of a part-select
    logic [7:0] c13;        assign c13 = din ^ 8'h0f;             // control: NON-cast op
  end

  assign dout = {24'h0, vb[0].c1} ^ {24'h0, vb[1].c2} ^ {24'h0, vb[0].c3} ^
                {24'h0, vb[1].c4} ^ {24'h0, vb[0].c5} ^ {24'h0, vb[1].c6} ^
                {24'h0, vb[0].c7} ^ {24'h0, vb[1].c8} ^ {24'h0, vb[0].c9} ^
                {24'h0, vb[1].c10} ^ {31'h0, vb[0].c11} ^ {24'h0, vb[1].c12} ^
                {24'h0, vb[0].c13};
endmodule
