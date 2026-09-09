// r10uvm225 arm a3_module — THE FENCE'S FIRST FACE.  The identical
// declarations under a MODULE definition: does the module road get array_nets?
class Cm225;
  int x;
endclass

typedef logic [7:0] tvm225_t;

module m225_kinds();
  typedef int tim225_t;
  Cm225       m_cls225;
  Cm225       m_fixcls225 [1:0];
  Cm225       m_dyncls225 [];
  tvm225_t    m_dyntv225  [];
  int         m_dynint225 [];
  int         m_qint225   [$];
  tvm225_t    m_astv225   [string];
  int         m_asint225  [int];
  tvm225_t    m_asnamed225 [tim225_t];
  int         m_fixint225 [2];
  logic [3:0] m_fixpk225  [1:0];
endmodule

module m225_np;
  Cm225       n_dyncls225 [];
  int         n_fixint225 [2];
  int         n_asint225  [string];
endmodule

module top225_mod(); endmodule
