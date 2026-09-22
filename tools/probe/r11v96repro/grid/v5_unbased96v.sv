// r11v96 VERIFIER arm v5 — THE UNBASED-UNSIZED LITERAL ON THE REDUCE ROAD.
// `red72Int64` reads `'1` through slang's store, which is 32 bits of ones;
// Surelog's `get_value` reads its own digit string.  The LANDED minus law
// already puts that reading on the net-decl-assign road, so this arm asks
// whether the disagreement predates r11u96's mult/div/mod widening.
package v5p;
  localparam int UMIN  = '1 - 0;      // the LANDED minus road
  localparam int USUB  = '1 - 1;
  localparam int UNEG  = -'1;         // the LANDED unary-minus road
  localparam int UMUL  = '1 * 2;      // r11u96's widened road
  localparam int UDIV  = '1 / 1;
  localparam int UMOD  = '1 % 7;
  localparam int UZER  = '0 - 0;      // the zero face
  localparam int UADD  = '1 + 0;      // the `+` control (no INT mint)
  localparam int UBARE = '1;          // no operator at all
endpackage
module v5_unbased96v (output logic [63:0] o);
  wire signed [31:0] wUMIN  = v5p::UMIN;
  wire signed [31:0] wUSUB  = v5p::USUB;
  wire signed [31:0] wUNEG  = v5p::UNEG;
  wire signed [31:0] wUMUL  = v5p::UMUL;
  wire signed [31:0] wUDIV  = v5p::UDIV;
  wire signed [31:0] wUMOD  = v5p::UMOD;
  wire signed [31:0] wUZER  = v5p::UZER;
  wire signed [31:0] wUADD  = v5p::UADD;
  wire signed [31:0] wUBARE = v5p::UBARE;
  assign o = {wUMIN, wUSUB} ^ {wUNEG, wUMUL} ^ {wUDIV, wUMOD} ^
             {wUZER, wUADD} ^ {wUBARE, wUMIN};
endmodule
