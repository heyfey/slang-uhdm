// r11v97 VERIFIER arm k7 — LAW C's `<width>'b<v>` DECOMPILE, TYPE BY TYPE.
// k1 found two declared types on which `adjustSize` does NOT re-render the
// one-bit answer at the declaration's width: `time` (golden `1'b1`, size 1)
// and a MULTI-DIMENSIONAL packed array (golden the BARE `1`, size 1, and no
// source range at all).  This arm walks the type axis around both of them so
// the fix's home predicate is measured and not guessed.
package k7p;
  typedef logic [2:0][3:0]    td_pa_t;
  typedef logic [7:0]         td_v8_t;
  typedef enum int { KX = 0, KY = 1 } k7e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } k7s_t;
  localparam logic [3:0]       QV4   = (3 < 4);
  localparam logic [0:7]       QASC  = (3 < 4);
  localparam bit   [7:0]       QB8   = (3 < 4);
  localparam reg   [7:0]       QR8   = (3 < 4);
  localparam logic signed [0:0] QS1  = (3 < 4);
  localparam logic [1:0][1:0]  QPA2  = (3 < 4);
  localparam logic [1:0][1:0][1:0] QPA3 = (3 < 4);
  localparam td_pa_t           QTPA  = (3 < 4);
  localparam td_v8_t           QTV8  = (3 < 4);
  localparam time              QTM   = (3 < 4);
  localparam time              QTMF  = (4 < 3);
  localparam realtime          QRT   = (3 < 4);
  localparam shortreal         QSR   = (3 < 4);
  localparam logic [2:0][3:0]  QPAF  = (4 < 3);
  localparam int               QINT  = (3 < 4);
  localparam logic [7:0]       QV8   = (3 < 4);
endpackage
module k7_cwidth94v (output logic [63:0] o);
  wire [3:0]  wQV4  = k7p::QV4;
  wire [7:0]  wQASC = k7p::QASC;
  wire [7:0]  wQB8  = k7p::QB8;
  wire [7:0]  wQR8  = k7p::QR8;
  wire        wQS1  = k7p::QS1;
  wire [3:0]  wQPA2 = k7p::QPA2;
  wire [7:0]  wQPA3 = k7p::QPA3;
  wire [11:0] wQTPA = k7p::QTPA;
  wire [7:0]  wQTV8 = k7p::QTV8;
  wire [63:0] wQTM  = k7p::QTM;
  wire [63:0] wQTMF = k7p::QTMF;
  wire [11:0] wQPAF = k7p::QPAF;
  wire signed [31:0] wQINT = k7p::QINT;
  wire [7:0]  wQV8  = k7p::QV8;
  assign o = {28'd0, wQV4, wQASC, wQB8, wQR8, 7'd0, wQS1} ^
             {28'd0, wQPA2, wQPA3, wQTPA, wQTV8} ^ wQTM ^ wQTMF ^
             {20'd0, wQPAF, wQINT} ^ {56'd0, wQV8};
endmodule
