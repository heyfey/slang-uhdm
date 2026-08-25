// v136 arm H — package split over two files, $unit face used from a package,
// interface/program homes, and the IN-CLASS union typespec characterisation.
typedef struct packed { bit [2:0] gA; bit [4:0] gB; } globalSpan_S;
typedef union  packed { bit [7:0] gU; bit [7:0] gV; } globalWrap_U;

package Pk_Split;
`include "v136_h_more_inc.svh"
  class SplitUser;
    splitSpan_S  i01_splitStruct;      // typedef from ANOTHER FILE of this package
    splitWrap_U  i02_splitUnion;
  endclass

  class InlineTd;                       // the in-class characterisation
    typedef struct packed { bit [3:0] icA; bit [3:0] icB; } icSpan_S;
    typedef union  packed { bit [7:0] icU; bit [7:0] icV; } icWrap_U;
    icSpan_S i05_inClassStruct;
    icWrap_U i06_inClassUnion;
  endclass
endpackage

interface if_home_v136;
  typedef struct packed { bit [1:0] ifA; bit [6:0] ifB; } ifSpan_S;
  class IfClass;
    ifSpan_S     i07_ifProp;
    globalWrap_U i08_ifUnion;
  endclass
  logic dummy_sig;
endinterface

program prog_home_v136;
  class ProgClass;
    globalSpan_S i09_progProp;
    globalWrap_U i10_progUnion;
  endclass
  initial begin end
endprogram

module mod_home_v136;
  if_home_v136 u_if();
  class ModCls;
    globalSpan_S i11_modProp;
  endclass
  ModCls a1, a2, a3;
endmodule
