// r10uvm225 arm a7_associdx — every associative INDEX form, in an interface
// (the array_net's range and its index typespec) and in a module (the control).
// R-A lives here: a CLASS-typed index.
class Cx225;
  int x;
endclass
typedef logic [7:0] tvx225_t;

package p225x;
  typedef int px225_t;
  typedef string ps225_t;
endpackage

interface if225_idx();
  typedef int tix225_t;
  typedef string tsx225_t;
  tvx225_t x_str225   [string];
  tvx225_t x_int225   [int];
  tvx225_t x_logic225 [logic];
  tvx225_t x_bit225   [bit];
  tvx225_t x_byte225  [byte];
  tvx225_t x_shint225 [shortint];
  tvx225_t x_integ225 [integer];
  tvx225_t x_pkbit225 [bit[7:0]];
  tvx225_t x_pklog225 [logic[3:0]];
  tvx225_t x_wild225  [*];
  tvx225_t x_named225 [tix225_t];
  tvx225_t x_tdstr225 [tsx225_t];
  tvx225_t x_pkgidx225 [p225x::px225_t];
  tvx225_t x_cls225   [Cx225];
endinterface

module m225_idx();
  typedef int tix225_t;
  tvx225_t y_str225   [string];
  tvx225_t y_named225 [tix225_t];
  tvx225_t y_cls225   [Cx225];
endmodule

module top225_idx(); endmodule
