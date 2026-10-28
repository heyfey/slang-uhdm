// § pkgDupSignalLeftoverNet451
package a;
  typedef logic [7:0] byte_t;
  typedef struct packed { logic [1:0] f; } ps_t;
  typedef enum {E0, E1} e_t;
  class C; int m; endclass
  int vi;
  logic [3:0] vl;
  bit vb;
  reg [2:0] vr;
  byte vy;
  integer vg;
  string vs;
  real vre;
  e_t ve;
  C vc;
  int ua [3];
  logic [1:0] ub [0:1];
  int q [$];
  int da [];
  int aa [string];
  byte_t vt;
  ps_t vp;
  struct packed { logic a; } vap;
  struct { int x; } vus;
  int vinit = 5;
  const int vk = 3;
  shortint vsh;
  longint vlg;
  time vtm;
  chandle vch;
  wire [1:0] w1;
endpackage
package b;
  import a::*;
endpackage
package c;
  import a::*;
  import b::*;
endpackage
module top;
endmodule
