// r10uvm149 arm C -- STRUCT HOMES: $unit / package / class-scope / module /
// an ANONYMOUS struct variable.  The UVM head lives in the CLASS-SCOPE home.
typedef struct {
  string unitArgs[$];
  int    unitUsed;
} unit_home_t;

unit_home_t unitLevelVar;

package Delta_pkg;
  typedef struct {
    string pkgArgs[$];
    int    pkgUsed;
  } pkg_home_t;
  pkg_home_t pkgLevelVar;
endpackage

class Carrier;
  typedef struct {
    string clsArgs[$];
    int    clsUsed;
  } cls_home_t;
  static cls_home_t applied[$];
  cls_home_t single;
endclass

module homes_top;
  typedef struct {
    string modArgs[$];
    int    modUsed;
  } mod_home_t;
  mod_home_t modLevelVar;
  struct {
    string anonArgs[$];
    int    anonUsed;
  } anonVar;
  initial modLevelVar.modUsed = 2;
endmodule
