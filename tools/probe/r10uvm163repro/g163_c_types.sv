// r10uvm163 / arm C — the PROPERTY TYPES: what a written `#(...)` may say, all
// declared in a `$unit` class holding a PACKAGE generic (arm A's cell a4, the
// Scoreboard shape), so the law fires on every one.
//
// The listing golden builds is transcribed from Surelog
// `CompileHelper::compileDatastructureTypespec`'s ClassDefinition arm
// (src/DesignCompile/CompileType.cpp:902-1000): it walks the WRITTEN ORDERED
// arguments, pairs argument i with `getOrderedParameters()[i]`, stops at
// `index < formal.size()`, and takes a DIFFERENT branch for an argument that
// parses as a `paData_type` (`int`) than for one that parses as an EXPRESSION
// (a class name).  Every cell below puts one clause of that loop to golden.
//
// LHS is ALWAYS golden(Surelog); RHS is always ours.

package epsilon163;
  class cfgEp163;
    int qq;
  endclass
  class plainEp163;            // NOT parameterized — a control target
    int qq;
  endclass
  class genEp163 #(type TA = int, type TB = int);
    TA aa;
    TB bb;
  endclass
  class oneEp163 #(type TA = int);
    TA aa;
  endclass
  class valEp163 #(int NN = 1, type TA = int);   // a VALUE formal FIRST
    TA aa;
  endclass
endpackage

import epsilon163::*;

class cfgUn163;
  int qq;
endclass

typedef logic [3:0] nib163_t;

class typesUn163;
  genEp163#(cfgUn163, cfgUn163) c1_two_class_args;  // #(type, type)
  genEp163#(int, int) c2_two_int_args;              // #(int, int)
  genEp163#(int, cfgUn163) c3_mixed_args;           // the SCOREBOARD spelling
  genEp163#(int) c4_one_arg_of_two;                 // ONE written arg of TWO
  oneEp163#(int) c5_single_formal;                  // #(int) on a 1-formal class
  genEp163#(nib163_t, cfgUn163) c6_typedef_arg;     // a TYPEDEF'd argument
  genEp163#(.TA(cfgUn163)) c7_named_arg;            // a NAMED argument
  genEp163 c8_bare_default;                         // the BARE generic name
  plainEp163 c9_nonparam;                           // a NON-parameterized class
  valEp163#(4, cfgUn163) c10_value_then_type;       // a VALUE arg then a type
endclass

module topC163;
  typesUn163 tu;
endmodule
