// r10uvm149 arm A -- MEMBER DIMENSION KINDS on one package struct typedef.
// Names/orders deliberately NOT parallel (a grid that calls everything
// a_t/b_t/c_t over A/B/C is self-confirming).
package Zeta_pkg;
  typedef string preQueued_t[$];
  typedef struct {
    int      plainScalar;
    string   Queued[$];
    string   NineFixed[9];
    string   Dyn[];
    string   RangeFixed[3:1];
    string   AssocInt[int];
    string   BoundedQ[$:7];
    string   AssocStr[string];
    string   TwoDim[2][4];
    string   AssocWild[*];
    logic [3:0] PackedPlusUnp[2];
    logic [3:0] PackedOnly;
    preQueued_t TypedefQ;
    string   QueueThenFixed[$][5];
    string   FixedThenQueue[5][$];
  } dimkinds_t;
  dimkinds_t theOne;
endpackage

module dims_top;
  import Zeta_pkg::*;
  dimkinds_t w1;
  initial w1.plainScalar = 4;
endmodule
