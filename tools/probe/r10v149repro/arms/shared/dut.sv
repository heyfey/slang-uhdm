// v149c arm -- A TYPEDEF'D TYPE SHARED between a [$] struct member and PLAIN
// (non-queue) declarations.  If the instance hand-down stamps a SHARED
// typespec object, the plain sites move too.
package Zed_pkg;
  typedef enum bit [2:0] { ONEV = 3'd1, TWOV = 3'd2 } shared_e;
  typedef struct { int sh_a; byte sh_b; } shared_s;
  typedef logic [6:0] shared_v;

  typedef struct {
    shared_e  qOfEnum[$];
    shared_s  qOfStruct[$];
    shared_v  qOfVec[$];
    shared_e  plainEnum;
    shared_s  plainStruct;
    shared_v  plainVec;
    shared_e  qOfEnumTwo[$];
  } sharer_t;

  sharer_t theSharer;
  shared_e  freeEnum;
  shared_s  freeStruct;
  shared_v  freeVec;
endpackage

module shared_top;
  import Zed_pkg::*;
  sharer_t s9;
  shared_e modEnum;
  initial modEnum = ONEV;
endmodule
