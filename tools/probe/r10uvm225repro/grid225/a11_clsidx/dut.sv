// r10uvm225 arm a11_clsidx — R-A: the associative reprieve over-fires on a
// CLASS-TYPED index.  `assocBuiltinIndexDim224` reprieves any index that is
// not a TypeAlias; a class handle is a legal index and is not a TypeAlias, so
// we KEEP the typespec where golden DROPS it.  Also the packed/enum/struct
// index forms the reprieve was never measured against.
class Ca225;
  int x;
endclass
class Cb225 extends Ca225;
  int y;
endclass
typedef logic [7:0] tva225_t;
typedef enum logic [1:0] { A0, A1 } ena225_t;
typedef struct packed { logic [3:0] a; logic [3:0] b; } spa225_t;

package p225c;
  class Cc225;
    int z;
  endclass
endpackage

interface if225_ci();
  tva225_t c_cls225    [Ca225];
  tva225_t c_clsder225 [Cb225];
  tva225_t c_pkgcls225 [p225c::Cc225];
  tva225_t c_enum225   [ena225_t];
  tva225_t c_struct225 [spa225_t];
  tva225_t c_str225    [string];
  tva225_t c_ctl225    [int];
endinterface

module m225_ci();
  tva225_t g_cls225  [Ca225];
  tva225_t g_enum225 [ena225_t];
  tva225_t g_str225  [string];
endmodule

module top225_ci(); endmodule
