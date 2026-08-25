// r10uvm136 arm F — PACKED ARRAYS as class properties: which leaf types make
// golden mint a packed_array_var, and which stay bit_var / logic_var.  This is
// the arm that FENCES the law's packed-array half (its corpus reach is zero;
// its grid reach is not).
package Fpk8;
  typedef struct packed { bit [7:0] xLo; bit [7:0] xHi; } cellSpan_F;
  typedef union  packed { bit [15:0] flatF; cellSpan_F splitF; } cellWrap_F;
  typedef enum bit [1:0] { F_P, F_Q } pick_e;
  typedef logic [3:0] nib_t;

  class ArrHold44;
    cellSpan_F [1:0]      f01_pastruct;
    cellSpan_F [1:0][2:0] f02_pastruct2d;
    cellWrap_F [3:0]      f03_paunion;
    pick_e     [1:0]      f04_paenum;
    bit        [1:0][7:0] f05_pabit;
    logic      [1:0][3:0] f06_palogic;
    nib_t      [2:0]      f07_patypedef;
    cellSpan_F            f08_scalarctl;
    bit        [7:0]      f09_bitvecctl;
  endclass
endpackage

module ftop;
  Fpk8::ArrHold44 a44;
  initial a44 = new();
endmodule
