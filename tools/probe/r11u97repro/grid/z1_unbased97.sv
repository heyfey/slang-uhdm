// r11u97 arm z1 — LAW A: THE UNBASED-UNSIZED LITERAL ON THE REDUCE ROAD.
// Surelog compiles `'1` to a constant `BIN:1` with `VpiSize(-1)`
// (CompileExpression.cpp:610-618, `paNumber_Tick1`) and `'0` to `BIN:0`, so
// `get_value` reads the DIGIT 1 / 0.  slang types the literal at the context
// width and fills it with ones, so our reduce reads 4294967295.  This arm
// crosses `'0`/`'1` with every operator on the int64 road and with three
// reader widths, and carries the based 1-bit leaf as the live control.
package z1p;
  localparam int  U1MIN  = '1 - 0;        // the landed minus road
  localparam int  U1SUB  = '1 - 1;
  localparam int  U1NEG  = -'1;           // the landed unary-minus road
  localparam int  U1MUL  = '1 * 2;        // r11u96's mult road
  localparam int  U1MULR = 2 * '1;        // the RIGHT operand
  localparam int  U1DIV  = '1 / 1;
  localparam int  U1DIVR = 6 / '1;
  localparam int  U1MOD  = '1 % 7;
  localparam int  U1SUBR = 5 - '1;
  localparam int  U0SUB  = '0 - 0;        // the zero face
  localparam int  U0MUL  = '0 * 5;
  localparam int  U0NEG  = -'0;
  localparam int  U0SUBR = 5 - '0;
  localparam int  U1DEEP = ('1 * 2) * 3;  // nested, depth 2
  localparam int  U1PAR  = (('1)) - 0;    // parenthesised
  localparam int  U1CHN  = U1MUL * 2;     // through a NAME
  localparam int  U1ADD  = '1 + 0;        // the `+` arm (UINT mint)
  localparam int  U1SHL  = '1 << 1;       // the shift arm (UINT mint)
  localparam int  U1AND  = '1 & 3;        // the bit-and arm (UINT mint)
  localparam int  U1BARE = '1;            // NO OPERATOR AT ALL
  localparam int  U0BARE = '0;
  localparam longint        U1L   = '1 - 0;   // a 64-bit declaration
  localparam logic [7:0]    U1U8  = '1 - 0;   // narrow UNSIGNED declaration
  localparam logic signed [3:0] U1S4 = '1 - 0;// narrow SIGNED declaration
  // ===== THE LIVE CONTROLS — none of these is an unbased-unsized literal.
  localparam int  CSUB  = 8 - 1;          // landed § pkgParamMinusIsIntReduce94
  localparam int  CMUL  = 2 * 3;          // landed § pkgParamMulDivModIsIntReduce96
  localparam int  CDIV  = 6 / 2;
  localparam int  CMOD  = 7 % 4;
  localparam int  CB1S  = 1'b1 - 0;       // a BASED one-bit leaf
  localparam int  CB1M  = 1'b1 * 2;
  localparam int  CADD  = 1 + 2;          // the `+` control
  localparam int  CLIT  = 6;
  localparam longint CDEC = 4294967296 - 0; // landed § unsizedDecLeafWrittenDigits96
endpackage
module z1_unbased97 (output logic [63:0] o);
  wire signed [31:0] wU1MIN  = z1p::U1MIN;
  wire signed [31:0] wU1SUB  = z1p::U1SUB;
  wire signed [31:0] wU1NEG  = z1p::U1NEG;
  wire signed [31:0] wU1MUL  = z1p::U1MUL;
  wire signed [31:0] wU1MULR = z1p::U1MULR;
  wire signed [31:0] wU1DIV  = z1p::U1DIV;
  wire signed [31:0] wU1DIVR = z1p::U1DIVR;
  wire signed [31:0] wU1MOD  = z1p::U1MOD;
  wire signed [31:0] wU1SUBR = z1p::U1SUBR;
  wire signed [31:0] wU0SUB  = z1p::U0SUB;
  wire signed [31:0] wU0MUL  = z1p::U0MUL;
  wire signed [31:0] wU0NEG  = z1p::U0NEG;
  wire signed [31:0] wU0SUBR = z1p::U0SUBR;
  wire signed [31:0] wU1DEEP = z1p::U1DEEP;
  wire signed [31:0] wU1PAR  = z1p::U1PAR;
  wire signed [31:0] wU1CHN  = z1p::U1CHN;
  wire signed [31:0] wU1ADD  = z1p::U1ADD;
  wire signed [31:0] wU1SHL  = z1p::U1SHL;
  wire signed [31:0] wU1AND  = z1p::U1AND;
  wire signed [31:0] wU1BARE = z1p::U1BARE;
  wire signed [31:0] wU0BARE = z1p::U0BARE;
  wire signed [63:0] wU1L    = z1p::U1L;
  wire        [7:0]  wU1U8   = z1p::U1U8;
  wire signed [3:0]  wU1S4   = z1p::U1S4;
  wire        [31:0] wU1MINU = z1p::U1MIN;   // the same cell, UNSIGNED reader
  wire        [63:0] wU1MINW = z1p::U1MIN;   // the same cell, WIDE reader
  wire signed [31:0] wCSUB   = z1p::CSUB;
  wire signed [31:0] wCMUL   = z1p::CMUL;
  wire signed [31:0] wCDIV   = z1p::CDIV;
  wire signed [31:0] wCMOD   = z1p::CMOD;
  wire signed [31:0] wCB1S   = z1p::CB1S;
  wire signed [31:0] wCB1M   = z1p::CB1M;
  wire signed [31:0] wCADD   = z1p::CADD;
  wire signed [31:0] wCLIT   = z1p::CLIT;
  wire signed [63:0] wCDEC   = z1p::CDEC;
  assign o = {wU1MIN, wU1SUB} ^ {wU1NEG, wU1MUL} ^ {wU1MULR, wU1DIV} ^
             {wU1DIVR, wU1MOD} ^ {wU1SUBR, wU0SUB} ^ {wU0MUL, wU0NEG} ^
             {wU0SUBR, wU1DEEP} ^ {wU1PAR, wU1CHN} ^ {wU1ADD, wU1SHL} ^
             {wU1AND, wU1BARE} ^ {wU0BARE, wU1MINU} ^ wU1L ^ wU1MINW ^
             {24'd0, wU1U8, 28'd0, wU1S4} ^ {wCSUB, wCMUL} ^ {wCDIV, wCMOD} ^
             {wCB1S, wCB1M} ^ {wCADD, wCLIT} ^ wCDEC;
endmodule
