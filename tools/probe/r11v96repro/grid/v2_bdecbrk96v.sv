// r11v96 VERIFIER arm v2 — LAW B BREAKERS.  The written-digits reader fires on
// every unsized decimal that stands as an OPERAND of an operation, for every
// caller of `red72Int64`, not only the mult/div/mod road.  This arm crosses
// the magnitude band the implementer's y2 does not hold (2^63, uint64 max,
// leading zeros, underscores, parentheses), the DECLARED type that is not
// `longint`, and the operators that are NOT on the INT-mint gate (`+`, `<<`,
// `&`, a comparison) where only the VALUE road can move.
package v2p;
  localparam longint U63   = 9223372036854775808 - 0;   // 2^63, int64 refuses
  localparam longint U64M  = 18446744073709551615 - 0;  // uint64 max
  localparam longint SEP   = 4_294_967_296 - 0;         // underscores
  localparam longint PAR   = (4294967296) - 0;          // parenthesised
  localparam longint LZ    = 0000004294967296 - 0;      // leading zeros
  localparam int     I32   = 4294967296 - 0;            // declared INT
  localparam byte    BY8   = 4294967296 - 0;            // declared BYTE
  localparam longint SHL   = 2147483648 << 1;           // a SHIFT top
  localparam longint AND   = 4294967296 & 4294967296;   // a bitwise AND top
  localparam longint CMPB  = (4294967296 > 5);          // a comparison top
  localparam longint SUB2  = 4294967297 - 4294967296;   // both sides big
  localparam longint MULB  = 3000000000 * 2;            // mult + big decimal
  localparam longint MODB  = 4294967296 % 7;            // mod + big decimal
  localparam longint NEGB  = -4294967296;               // unary minus
  localparam longint NEST  = (4294967296 - 0) - 0;      // nested
  localparam longint CHAIN = SEP - 0;                   // a CHAIN over one
  localparam longint C30   = 1073741824 - 0;            // control, fits
  localparam longint CB    = 64'd4294967296 - 0;        // control, BASED
endpackage
module v2_bdecbrk96v (output logic [63:0] o);
  wire signed [63:0] wU63   = v2p::U63;
  wire signed [63:0] wU64M  = v2p::U64M;
  wire signed [63:0] wSEP   = v2p::SEP;
  wire signed [63:0] wPAR   = v2p::PAR;
  wire signed [63:0] wLZ    = v2p::LZ;
  wire signed [63:0] wI32   = v2p::I32;
  wire signed [63:0] wBY8   = v2p::BY8;
  wire signed [63:0] wSHL   = v2p::SHL;
  wire signed [63:0] wAND   = v2p::AND;
  wire signed [63:0] wCMPB  = v2p::CMPB;
  wire signed [63:0] wSUB2  = v2p::SUB2;
  wire signed [63:0] wMULB  = v2p::MULB;
  wire signed [63:0] wMODB  = v2p::MODB;
  wire signed [63:0] wNEGB  = v2p::NEGB;
  wire signed [63:0] wNEST  = v2p::NEST;
  wire signed [63:0] wCHAIN = v2p::CHAIN;
  wire signed [63:0] wC30   = v2p::C30;
  wire signed [63:0] wCB    = v2p::CB;
  assign o = wU63 ^ wU64M ^ wSEP ^ wPAR ^ wLZ ^ wI32 ^ wBY8 ^ wSHL ^
             wAND ^ wCMPB ^ wSUB2 ^ wMULB ^ wMODB ^ wNEGB ^ wNEST ^
             wCHAIN ^ wC30 ^ wCB;
endmodule
