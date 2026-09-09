// r10uvm225 arm a10_structelem — the INNER ELEMENT NET's fields (R-B), per
// container kind and per element kind.  `innernt224.py` scores this arm.
typedef struct packed { logic [3:0] a; logic [3:0] b; } sps225_t;
typedef struct { int a; string b; } sus225_t;
typedef logic [7:0] tvs225_t;
typedef enum logic [1:0] { E0, E1 } ens225_t;
class Cs225;
  int x;
endclass

package p225s;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } psps225_t;
endpackage

interface if225_se();
  sps225_t  s_fixsp225 [1:0];
  sps225_t  s_dynsp225 [];
  sps225_t  s_qsp225   [$];
  sps225_t  s_assp225  [string];
  sus225_t  s_fixsu225 [1:0];
  sus225_t  s_dynsu225 [];
  ens225_t  s_fixen225 [1:0];
  ens225_t  s_dynen225 [];
  tvs225_t  s_fixtv225 [1:0];
  tvs225_t  s_dyntv225 [];
  Cs225     s_dyncls225 [];
  int       s_dynint225 [];
  real      s_dynreal225 [];
  string    s_dynstr225 [];
  p225s::psps225_t s_dynpq225 [];
endinterface

module top225_se();
  if225_se u_se225();
endmodule
