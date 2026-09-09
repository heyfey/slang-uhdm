// r10uvm225 arm a2_ifinst — the SAME kinds in an interface that IS
// instantiated: the definition view AND the elaborated view side by side.
class Ci225;
  int x;
endclass

typedef logic [7:0] tvi225_t;

interface if225_inst();
  typedef int tii225_t;
  Ci225       i_cls225;
  Ci225       i_fixcls225 [1:0];
  Ci225       i_dyncls225 [];
  tvi225_t    i_dyntv225  [];
  int         i_dynint225 [];
  int         i_qint225   [$];
  tvi225_t    i_astv225   [string];
  int         i_asint225  [int];
  tvi225_t    i_asnamed225 [tii225_t];
  int         i_fixint225 [2];
endinterface

module top225_inst();
  if225_inst u_if225();
endmodule
