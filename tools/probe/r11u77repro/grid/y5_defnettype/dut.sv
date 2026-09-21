// r11u77 y5 — THE DEF-VIEW HOISTED NET'S `vpiNetType`, SPELLING BY SPELLING.
// The def view lists EVERY hoisted entry as a plain `logic_net`
// (UhdmWriter::writeNets always `MakeLogic_net` when `instance == nullptr`)
// and stamps `getVpiNetType(Signal::getType())` on it.  Our rule is "a
// FOUR-STATE INTEGRAL declaration is stamped 36" (r10apb3 repro 11), which is
// right for `logic` and for a `typedef logic [3:0]` and WRONG for a packed
// struct and an enum (y2: golden writes none, we write 36).  This arm asks
// the whole spelling table, the net keywords included.
package pd;
  logic  [15:0]    d_logic;
  reg    [15:0]    d_reg;
  integer          d_integer;
  time             d_time;
  bit    [15:0]    d_bit;
  typedef logic [3:0] word_t;
  word_t           d_tdlogic;      // a SIMPLE integral typedef
  typedef word_t   word2_t;
  word2_t          d_tdtd;         // a typedef OF a typedef
  typedef logic [1:0][7:0] parr_t;
  parr_t           d_tdparr;       // a PACKED-ARRAY typedef
  typedef struct packed { logic [7:0] x; logic [7:0] y; } st_t;
  st_t             d_tdstruct;
  typedef enum logic [1:0] { DA, DB } en_t;
  en_t             d_tdenum;
  typedef union packed { logic [7:0] a; logic [7:0] b; } un_t;
  un_t             d_tdunion;
  wire   [15:0]    d_wire;
  tri    [15:0]    d_tri;
  wand   [15:0]    d_wand;
  wor    [15:0]    d_wor;
  supply0          d_sup0;
  supply1          d_sup1;
  tri0   [15:0]    d_tri0;
  trireg [15:0]    d_trireg;
endpackage

module dut (output logic [31:0] o);
  import pd::*;
  assign o = 32'd0;
endmodule
