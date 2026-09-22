// r11u84 t2 - THE EXPLICIT-IMPORT CLONE, ENTRY KIND BY ENTRY KIND.
// `importPackage` filters BOTH data arms by `object_name`
// (CompileHelper.cpp:174-189): a variable arm `scope->addVariable` and a net
// arm `scope->getSignals().push_back`.  So an explicit `import p::n` clones
// exactly the one entry named `n`, whatever vector it rides.  Only the
// spellings Surelog accepts are scored here; the ones it ERRORS on are
// measured in t5_expfences and are not this law's ground.
package e1;
  wire  [7:0] x_net;
  logic [7:0] x_var = 8'd3;
  logic [7:0] x_uarr [0:1];
  typedef struct packed { logic a; logic b; } xg_t;
  xg_t        x_glogic;
  typedef logic [7:0] xw_t;
  wire xw_t   x_wtd;
  xw_t        x_wv;
  typedef reg [7:0] xr_t;
  xr_t        x_rv;
  bit   [7:0] x_bit;
  real        x_real;
  string      x_str;
  integer     x_int;
  wand  [7:0] x_wand;
  supply0     x_sup;
  parameter int XP = 5;
  typedef logic [3:0] xt_t;
endpackage

package e2;  import e1::x_net;     logic [7:0] o2; endpackage
package e3;  import e1::x_var;     logic [7:0] o3; endpackage
package e4;  import e1::x_uarr;    logic [7:0] o4; endpackage
package e6;  import e1::x_glogic;  logic [7:0] o6; endpackage
package e8;  import e1::x_wtd;     logic [7:0] o8; endpackage
package e9;  import e1::x_wv;      logic [7:0] o9; endpackage
package ea;  import e1::x_rv;      logic [7:0] oa; endpackage
package eb;  import e1::x_bit;     logic [7:0] ob; endpackage
package ec;  import e1::x_real;    logic [7:0] oc; endpackage
package ed;  import e1::x_str;     logic [7:0] od; endpackage
package ee;  import e1::x_int;     logic [7:0] oe; endpackage
package ef;  import e1::x_wand;    logic [7:0] of_; endpackage
package eg;  import e1::x_sup;     logic [7:0] og; endpackage
package eh;  import e1::XP;        logic [7:0] oh; endpackage
package ei;  import e1::xt_t;      logic [7:0] oi; endpackage

module dut (output logic [31:0] o);
  import e2::*; import e3::*; import e4::*; import e6::*;
  import e8::*; import e9::*; import ea::*; import eb::*; import ec::*;
  import ed::*; import ee::*; import ef::*; import eg::*; import eh::*;
  import ei::*;
  assign o = {24'd0, o2 ^ o3 ^ o4 ^ o6 ^ o8 ^ o9 ^ oa ^ ob ^ oc
                     ^ od ^ oe ^ of_ ^ og ^ oh ^ oi};
endmodule
