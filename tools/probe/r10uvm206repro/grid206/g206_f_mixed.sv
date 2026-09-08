// r10uvm206 grid arm F — THE SOURCE-KIND CROSS.  The unit's OWN typedefs (an
// enum, a struct, a packed vector and a nettype) sit in the same DataTypeMap
// as the imported package's typedefs and class keys, so this arm measures that
// the class keys merge into the one alphabetical run without displacing any of
// the kinds the listing already carried.
package pf206;
  class cf206_self;
    typedef cf206_self this_type;
    int s;
  endclass
  typedef logic [3:0] tf206_nib;
endpackage

import pf206::*;

typedef enum logic [1:0] { AF206 = 0, BF206 = 1 } uf206_enum;
typedef struct packed { logic [3:0] x; logic [3:0] y; } vf206_struct;
typedef logic [7:0] wf206_byte;
nettype real xf206_net;

module gf206;
  uf206_enum   e0;
  vf206_struct s0;
  wf206_byte   b0;
  tf206_nib    n0;
  cf206_self   h0;
endmodule
