// r11u104 arm r4 — THE EDGES OF THE HAND-OFF.  Unknown leaves at a narrower
// and a wider reader (golden keeps a BIN with the X digits), a name hop to
// one, a based literal with an unknown digit, a 4-state `integer` holding 'x;
// and the net kinds that must carry NO width: an enum-typed net, a packed
// struct net, an unpacked array net, a predefined-integer variable, and a
// `logic` variable with an initializer.
package r4p;
  localparam int      CUX   = 'x;
  localparam int      CUZ   = 'z;
  localparam int      CUXN  = CUX;
  localparam logic [7:0] BX8 = 8'b1x0x_0000;
  localparam logic [7:0] BZ8 = 8'bzzzz_1111;
  localparam integer  IX    = 'x;
  localparam integer  I4    = 300;
  localparam longint  BLB   = 9223372036854775807;
  localparam int      CLIT  = 300;
  localparam int      CPW   = 2 ** 3;
  typedef enum logic [3:0] {E0, E1, E2} e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
endpackage
module r4_edges104 (output logic [63:0] o);
  wire [7:0]   wCUX_n8   = r4p::CUX;
  wire [63:0]  wCUX_n64  = r4p::CUX;
  wire [3:0]   wCUZ_n4   = r4p::CUZ;
  wire [7:0]   wCUXN_n8  = r4p::CUXN;
  wire [3:0]   wBX8_n4   = r4p::BX8;
  wire [15:0]  wBX8_n16  = r4p::BX8;
  wire [3:0]   wBZ8_n4   = r4p::BZ8;
  wire [7:0]   wIX_n8    = r4p::IX;
  wire [7:0]   wI4_n8    = r4p::I4;
  wire [63:0]  wI4_n64   = r4p::I4;
  wire r4p::e_t wEN_e     = r4p::e_t'(r4p::CLIT);
  wire r4p::s_t wST_s     = r4p::CLIT;
  wire [7:0]   wARR [2]  = '{r4p::CLIT, r4p::CPW};
  int          vINT      = r4p::BLB;
  logic [7:0]  vLOG8     = r4p::CLIT;
  wire logic signed [0:0] wS1 = r4p::CLIT;
  wire logic [7:0] wLG8 = r4p::BLB;
  assign o = {wCUX_n8, wCUZ_n4, wCUXN_n8, wBX8_n4, wBZ8_n4, wIX_n8, wI4_n8,
              wEN_e, wST_s, wARR[0], vLOG8, wS1, wLG8} ^ wCUX_n64 ^ wBX8_n16 ^
             wI4_n64 ^ vINT;
endmodule
