// r10earl56 VERIFIER arm v3 — THE PARAMETER-KIND BATTERY at d0 AND d1.
// genScopeDeclaredParam56 tests only SymbolKind::Parameter + parent scope kind,
// so it fences EVERY gen-scope-declared value parameter regardless of type.
// At d1 the safety of that depends on genLpFoldByPath having REGISTERED the
// parameter (ModuleEmit only registers an IntegerLiteral init or a foldable
// integer constant), so each kind is measured at d1 too: if a kind is not
// registered, earl47 refuses, the pristine binary folded it here and the fence
// would be a REGRESSION.
module v3_sub56 #(parameter int unsigned Depth = 4)
                (input logic [31:0] din, output logic [31:0] o);
  if (Depth != 0) begin : gen_k
    localparam int unsigned KI = 3;        // typed int unsigned, literal
    localparam logic [3:0]  KL = 4'd3;     // packed logic vector
    localparam bit [2:0]    KB = 3'b011;   // packed bit, BINARY literal
    localparam int signed   KS = 3;        // signed
    localparam              KU = 3;        // untyped
    localparam int          KH = 'h3;      // HEX literal
    localparam int          KN = $clog2(8);        // non-literal init
    localparam int          KN2 = KN + 1;          // reads a sibling
    localparam int          KD = Depth - 1;        // reads the MODULE param
    parameter  int          KP = 3;        // `parameter` keyword in a gen scope
    typedef enum int {E0 = 0, E3 = 3} v3_e;
    localparam v3_e         KE = E3;       // ENUM-typed

    logic [31:0] x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11;
    assign x1  = {29'b0, din[0 +: KI]};
    assign x2  = {28'b0, din[0 +: KL]};
    assign x3  = {29'b0, din[0 +: KB]};
    assign x4  = {29'b0, din[0 +: KS]};
    assign x5  = {29'b0, din[0 +: KU]};
    assign x6  = {29'b0, din[0 +: KH]};
    assign x7  = {29'b0, din[0 +: KN]};
    assign x8  = {28'b0, din[0 +: KN2]};
    assign x9  = {29'b0, din[0 +: KD]};
    assign x10 = {29'b0, din[0 +: KP]};
    assign x11 = {28'b0, din[0 +: KE]};

    // the same kinds as a BARE part_select LEFT bound
    logic [31:0] y1,y2,y3,y4,y5;
    assign y1 = {29'b0, din[KI:1]};
    assign y2 = {28'b0, din[KL:1]};
    assign y3 = {29'b0, din[KN:1]};
    assign y4 = {28'b0, din[KE:1]};
    assign y5 = {29'b0, din[KP:1]};

    // ---- d1: EVERY kind again, one gen scope deeper -------------------
    if (Depth != 0) begin : gen_ki
      logic [31:0] z1,z2,z3,z4,z5,z6,z7,z8,z9,z10,z11;
      assign z1  = {29'b0, din[0 +: KI]};
      assign z2  = {28'b0, din[0 +: KL]};
      assign z3  = {29'b0, din[0 +: KB]};
      assign z4  = {29'b0, din[0 +: KS]};
      assign z5  = {29'b0, din[0 +: KU]};
      assign z6  = {29'b0, din[0 +: KH]};
      assign z7  = {29'b0, din[0 +: KN]};
      assign z8  = {28'b0, din[0 +: KN2]};
      assign z9  = {29'b0, din[0 +: KD]};
      assign z10 = {29'b0, din[0 +: KP]};
      assign z11 = {28'b0, din[0 +: KE]};
      logic [31:0] w1,w2,w3;
      assign w1 = {29'b0, din[KI:1]};
      assign w2 = {28'b0, din[KE:1]};
      assign w3 = {29'b0, din[KP:1]};
    end

    assign o = x1^x2^x3^x4^x5^x6^x7^x8^x9^x10^x11^y1^y2^y3^y4^y5;
  end
endmodule

module v3_paramkinds56 (input logic [31:0] din, output logic [31:0] o1);
  v3_sub56 #(.Depth(4)) u_s (.din(din), .o(o1));
endmodule
