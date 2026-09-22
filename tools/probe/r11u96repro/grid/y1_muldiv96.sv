// r11u96 arm y1 — LAW A, the MULT/DIV/MOD reduce arms.  `ExprEval.cpp:3479`
// (`vpiMultOp`), `:3803` (`vpiDivOp`) and `:3709` (`vpiModOp`) mint
// `"INT:" + std::to_string(val)` with `vpiIntConst` and an UNMASKED `int64_t`,
// exactly as the landed `vpiSubOp` arm does.  The grid crosses the three
// operators with operand signs, declared widths and the overflow face, and
// carries `+`, `<<`, `**`, `~` and the bare literals as live controls.
package y1p;
  localparam int           XMUL  = 2 * 3;
  localparam int           XDIV  = 6 / 2;
  localparam int           XMOD  = 7 % 4;
  localparam int           MZERO = 0 * 5;
  localparam int           MONE  = 1 * 1;
  localparam int           DTRUN = 7 / 2;
  localparam int           MODZ  = 4 % 4;
  localparam int           MNEG  = (-2) * 3;
  localparam int           DNEG  = (-6) / 2;
  localparam int           MODN  = (-7) % 4;
  localparam logic [7:0]   MU8   = 100 * 3;
  localparam logic [7:0]   DU8   = 6 / (-2);
  localparam logic [7:0]   MODU8 = (-7) % 4;
  localparam bit [3:0]     MB4   = 5 * 5;
  localparam int           MBIG  = 100000 * 100000;
  localparam byte          MBY   = 100 * 3;
  localparam int           MNEST = 2 * (3 - 1);
  localparam int           MCHN  = XMUL * 2;
  localparam int           DCHN  = XMUL / 2;
  localparam logic [7:0]   MHEX  = 8'h10 * 2;
  // the CONTROLS — every one of these must stay exactly where it is
  localparam int           CADD  = 1 + 2;
  localparam int           CSHL  = 1 << 3;
  localparam int           CPOW  = 2 ** 3;
  localparam int           CNOT  = ~0;
  localparam int           CLIT  = 6;
  localparam logic [7:0]   CHEX  = 8'hff;
  localparam int           CCAST = int'(2 * 3);
  localparam int           CSUB  = 8 - 1;
endpackage
module y1_muldiv96 (output logic [63:0] o);
  wire signed [31:0] wXMUL  = y1p::XMUL;
  wire signed [31:0] wXDIV  = y1p::XDIV;
  wire signed [31:0] wXMOD  = y1p::XMOD;
  wire signed [31:0] wMZERO = y1p::MZERO;
  wire signed [31:0] wMONE  = y1p::MONE;
  wire signed [31:0] wDTRUN = y1p::DTRUN;
  wire signed [31:0] wMODZ  = y1p::MODZ;
  wire signed [31:0] wMNEG  = y1p::MNEG;
  wire signed [31:0] wDNEG  = y1p::DNEG;
  wire signed [31:0] wMODN  = y1p::MODN;
  wire signed [31:0] wMU8   = y1p::MU8;
  wire signed [31:0] wDU8   = y1p::DU8;
  wire signed [31:0] wMODU8 = y1p::MODU8;
  wire signed [31:0] wMB4   = y1p::MB4;
  wire signed [63:0] wMBIG  = y1p::MBIG;
  wire signed [31:0] wMBY   = y1p::MBY;
  wire signed [31:0] wMNEST = y1p::MNEST;
  wire signed [31:0] wMCHN  = y1p::MCHN;
  wire signed [31:0] wDCHN  = y1p::DCHN;
  wire signed [31:0] wMHEX  = y1p::MHEX;
  wire signed [31:0] wCADD  = y1p::CADD;
  wire signed [31:0] wCSHL  = y1p::CSHL;
  wire signed [31:0] wCPOW  = y1p::CPOW;
  wire signed [31:0] wCNOT  = y1p::CNOT;
  wire signed [31:0] wCLIT  = y1p::CLIT;
  wire signed [31:0] wCHEX  = y1p::CHEX;
  wire signed [31:0] wCCAST = y1p::CCAST;
  wire signed [31:0] wCSUB  = y1p::CSUB;
  assign o = {wXMUL, wXDIV} ^ {wXMOD, wMZERO} ^ {wMONE, wDTRUN} ^
             {wMODZ, wMNEG} ^ {wDNEG, wMODN} ^ {wMU8, wDU8} ^
             {wMODU8, wMB4} ^ wMBIG ^ {wMBY, wMNEST} ^ {wMCHN, wDCHN} ^
             {wMHEX, wCADD} ^ {wCSHL, wCPOW} ^ {wCNOT, wCLIT} ^
             {wCHEX, wCCAST} ^ {wCSUB, wXMUL};
endmodule
