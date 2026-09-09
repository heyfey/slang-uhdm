// r10uvm225 arm a5_imported — THE MiniAmiq ASSOCIATIVE PAIR.  The
// wildcard-imported package data that § wildcardImportCopiesPkgVarsToDefNets223
// hoists into the def-view net list: does the HOISTED copy get an array_net,
// and does an interface importing the SAME package TWICE list it twice?
class Cg225;
  int x;
endclass

package p225a;
  class Cq225;
    int y;
  endclass
  typedef logic [7:0] tvq225_t;
  Cq225    pg_ascls225 [string];   // the uvm_random_seed_table_lookup shape
  tvq225_t pg_astv225  [string];
  Cq225    pg_dyncls225 [];
  int      pg_fixint225 [2];
  int      pg_qint225   [$];
  int      pg_plain225;
endpackage

package p225b;
  import p225a::*;
  export p225a::*;
  int qg_dynint225 [];
endpackage

// ONE wildcard import
interface if225_imp1();
  import p225a::*;
  Cg225 w_dyncls225 [];
endinterface

// TWO wildcard imports reaching the same names (MiniAmiq imports svaunit_pkg
// and uvm_pkg, and the seed table arrives on both roads)
interface if225_imp2();
  import p225b::*;
  import p225a::*;
  Cg225 x_dyncls225 [];
endinterface

// EXPLICIT single-name import
interface if225_imp3();
  import p225a::pg_ascls225;
  Cg225 y_dyncls225 [];
endinterface

// the module control for the same import
module m225_imp();
  import p225a::*;
  Cg225 z_dyncls225 [];
endmodule

module top225_imp(); endmodule
