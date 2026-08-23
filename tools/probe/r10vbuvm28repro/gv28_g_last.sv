// r10vbuvm28 arm G — the last shapes the brief names: class TYPE ARGUMENTS,
// a base-less enum as a function return / formal, a struct RETURN, a
// constraint, a virtual interface, and $bits under a foreach loop variable.
package pg;
  typedef enum { A, B } ge_t;
  typedef struct packed { ge_t c; bit [7:0] d; } gs_t;
endpackage

interface vif;
  pg::ge_t s;
endinterface

class box #(type T = int);
  T m_t;
  function int f(); return $bits(T) + $bits(m_t); endfunction
endclass

class user;
  typedef enum { U0, U1 } ue_t;
  rand ue_t m_u;
  ue_t      m_arr [4];
  pg::gs_t  m_s;
  virtual vif m_vif;
  bit       z [];
  constraint c1 { m_u inside {U0, U1}; }
  function ue_t retenum(ue_t f); return f; endfunction
  function pg::gs_t retstruct(); pg::gs_t s; return s; endfunction
  function void go();
    int acc;
    z = new [$bits(m_u)];
    z = new [$bits(ue_t)];
    z = new [$bits(m_s)];
    z = new [$bits(pg::gs_t)];
    acc = $bits(m_arr[0]);
    foreach (m_arr[i]) acc += $bits(m_arr[i]);
    acc += $bits(retenum(U0));
    acc += $bits(retstruct());
  endfunction
endclass

module gv28_g_last;
  import pg::*;
  box #(ge_t)  b1;
  box #(gs_t)  b2;
  box #(int)   b3;
  vif u_vif ();
  ge_t mv;
  int  r [6];
  initial begin
    r[0] = $bits(ge_t);
    r[1] = $bits(gs_t);
    r[2] = $bits(u_vif.s);
    r[3] = $bits(mv);
  end
endmodule
