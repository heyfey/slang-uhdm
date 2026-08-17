// verifier arm B -- every HOME for the typedef that is used as an enum base,
// and every HOME for the enum itself.
package pb10;
  typedef bit [7:0] tb_pkg;
  typedef tb_pkg    tb_pkg_c;
  typedef enum tb_pkg   { P0 = 0, P1 = 1 } e_pkg;
  typedef enum tb_pkg_c { PC0 = 0, PC1 = 1 } e_pkg_c;

  class cin10;
    typedef logic [5:0] tb_cls;
    typedef tb_cls      tb_cls_c;
    typedef enum tb_cls   { K0 = 0, K1 = 1 } e_cls;
    typedef enum tb_cls_c { KC0 = 0, KC1 = 1 } e_cls_c;
    e_cls   a1;
    e_cls_c a2;
  endclass
endpackage

class cout10;
  typedef bit [4:0] tb_co;
  typedef tb_co     tb_co_c;
  typedef enum tb_co   { X0 = 0, X1 = 1 } e_co;
  typedef enum tb_co_c { XC0 = 0, XC1 = 1 } e_co_c;
  e_co   b1;
  e_co_c b2;
endclass

interface vbIf10;
  typedef bit [2:0] tb_if;
  typedef tb_if     tb_if_c;
  typedef enum tb_if   { I0 = 0, I1 = 1 } e_if;
  typedef enum tb_if_c { IC0 = 0, IC1 = 1 } e_if_c;
  e_if   c1;
  e_if_c c2;
endinterface

program vbPg10;
  typedef bit [6:0] tb_pg;
  typedef tb_pg     tb_pg_c;
  typedef enum tb_pg   { R0 = 0, R1 = 1 } e_pg;
  typedef enum tb_pg_c { RC0 = 0, RC1 = 1 } e_pg_c;
  e_pg   d1;
  e_pg_c d2;
endprogram

module vbTop10;
  import pb10::*;
  typedef bit [3:0] tb_mod;
  typedef tb_mod    tb_mod_c;
  typedef enum tb_mod   { M0 = 0, M1 = 1 } e_mod;
  typedef enum tb_mod_c { MC0 = 0, MC1 = 1 } e_mod_c;
  e_mod    m1;
  e_mod_c  m2;
  e_pkg    m3;
  e_pkg_c  m4;
  pb10::cin10 m5;
  cout10      m6;

  if (1) begin : g10
    typedef bit [1:0] tb_gen;
    typedef tb_gen    tb_gen_c;
    typedef enum tb_gen   { N0 = 0, N1 = 1 } e_gen;
    typedef enum tb_gen_c { NC0 = 0, NC1 = 1 } e_gen_c;
    e_gen   n1;
    e_gen_c n2;
  end
endmodule
