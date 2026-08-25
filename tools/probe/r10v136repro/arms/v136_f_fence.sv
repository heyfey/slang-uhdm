// v136 arm F — the FENCE: genuine PACKED arrays (dims BEFORE the name) and
// their must-not-move leaves.
package Pk_Fence;
  typedef struct packed { bit [3:0] fA; bit [3:0] fB; } fenceSpan_S;
  typedef union  packed { bit [7:0] fU; bit [7:0] fV; } fenceWrap_U;
  typedef enum bit [1:0] { F_LOW, F_MID, F_HIGH } fpick_e;
  typedef logic [3:0] fnib_t;

  class FenceProps;
    fenceSpan_S [1:0]        g01_pastruct;
    fenceSpan_S [1:0][2:0]   g02_pastruct2d;
    fenceWrap_U [3:0]        g03_paunion;
    fpick_e     [1:0]        g04_paenum;
    bit   [1:0][7:0]         g05_pabit;
    logic [1:0][3:0]         g06_palogic;
    fnib_t      [2:0]        g07_patypedef;
    fenceSpan_S              g08_scalarctl;
    fenceWrap_U              g09_uscalarctl;
    bit   [7:0]              g10_bitvecctl;
    fenceSpan_S              g11_unpackarr [2];
    fenceSpan_S [1:0]        g12_pa_then_unpack [2];
  endclass
endpackage
