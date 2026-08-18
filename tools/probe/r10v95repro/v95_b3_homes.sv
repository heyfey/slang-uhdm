// r10v95 arm b3 — HOMES: package fn/task, class in-body / out-of-block /
// static, module function/task/always, interface, program, $unit.
typedef logic [17:0] u18_t;

package p3;
  typedef logic [9:0] t10_t;
  class InC;
    byte       m_dyn [];
    t10_t      m_fix [3];
    logic [30:0] m_vec;
    real       m_re;
    time       m_tm;
    string     m_st;
    function int inb();
      int a;
      a = $bits(m_dyn[0]);
      a = a + $bits(m_fix[1]);
      a = a + $bits(m_vec[4]);
      a = a + $bits(m_vec[9:2]);
      a = a + $bits(m_re);
      a = a + $bits(m_tm);
      a = a + $bits(m_st);
      return a;
    endfunction
    extern function int oob();
    static function int stat();
      logic [12:0] loc13;
      return $bits(loc13[2]);
    endfunction
  endclass
  function int InC::oob();
    int b;
    b = $bits(m_dyn[0]);
    b = b + $bits(m_fix[1]);
    b = b + $bits(byte);
    b = b + $bits(m_vec[4]);
    return b;
  endfunction
  function automatic int pfn(input int z);
    logic [21:0] q22;
    byte         qd [];
    return $bits(q22[3]) + $bits(qd[0]) + z;
  endfunction
  task automatic ptk(output int y);
    logic [6:0] s7 [2];
    y = $bits(s7[1][3:1]);
  endtask
endpackage

interface if3;
  logic [27:0] ibus;
  byte         iarr [4];
  function automatic int ifn();
    return $bits(ibus[5]) + $bits(iarr[2]);
  endfunction
endinterface

program prg3;
  logic [19:0] pgv;
  byte         pgd [];
  initial begin
    int k;
    k = $bits(pgv[8:1]) + $bits(pgd[0]);
  end
endprogram

module b3;
  logic [11:0] mv;
  byte         mdyn [];
  int          o1, o2, o3;
  p3::InC      inst;
  function automatic int mfn();
    return $bits(mv[2]) + $bits(mdyn[1]);
  endfunction
  task automatic mtk(output int t);
    t = $bits(mv[5:0]);
  endtask
  always_comb o1 = $bits(mv[1]);
  initial begin
    o2 = mfn();
    mtk(o3);
    o3 = o3 + $bits(u18_t);
  end
endmodule
