`include "defs.svh"
package q;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:`VAL, D:8};
endpackage
