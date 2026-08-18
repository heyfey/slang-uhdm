// r10vbuvm21repro/v2home.sv — ADVERSARIAL HOME arm: every class/subroutine home
// the law claims (in-body class method in a package / module / $unit, $unit free
// subroutine) plus the ones it does not name: inheritance + super, constructor,
// static / virtual / extern-OOB, parameterized and nested classes, a class in a
// program and in an interface, and every formal DIRECTION.
package vp2;
  typedef enum { A2, B2 } ve2;
  class base2;
    int baa[ve2];
    function new(); baa[A2] = 0; endfunction
    function void b_inc(ve2 s);              baa[s]++;            endfunction
    virtual function void b_vinc(ve2 s);     baa[s]++;            endfunction
  endclass
  class der2 extends base2;
    int daa[ve2];
    function new(ve2 s);   super.new(); daa[s]++;                 endfunction
    virtual function void b_vinc(ve2 s);     daa[s]++;            endfunction
    static function void s_inc(ve2 s);       int sl[ve2]; sl[s]++; endfunction
    extern function void e_inc(ve2 s);
    function void r_inc(ref int r);          r++;                 endfunction
    function void io_inc(inout int io);      io++;                endfunction
    function void o_inc(output int o);       o = 0; o++;          endfunction
    function void d_inc(ve2 s = A2);         daa[s]++;            endfunction
    task t_inc(ve2 s);                       daa[s]++;            endtask
    function void loc_inc();                 int lc; lc++;        endfunction
  endclass
  function void der2::e_inc(ve2 s);          daa[s]++;            endfunction
  class parm2 #(int W = 4);
    int paa[ve2];
    function void p_inc(ve2 s);              paa[s]++;            endfunction
  endclass
  class outer2;
    int oaa[ve2];
    function void o_inc(ve2 s);              oaa[s]++;            endfunction
  endclass
  class inner2;
    int iaa[ve2];
    function void i_inc(ve2 s);              iaa[s]++;            endfunction
  endclass
  int pkg_arr[ve2];
  function void pf_inc(ve2 s);               pkg_arr[s]++;        endfunction
  task pt_inc(ve2 s);                        pkg_arr[s]++;        endtask
endpackage

module vm2;
  import vp2::*;
  parm2 #(8) ph;
  parm2 #(4) ph2;
  der2 dh;
  outer2 oh;
  int marr[2];
  function void mf_inc(int s);               marr[s]++;           endfunction
  initial begin
    ph = new(); ph2 = new(); dh = new(A2); oh = new();
    ph.p_inc(A2); ph2.p_inc(B2); dh.e_inc(A2); oh.o_inc(A2);
    mf_inc(0);
  end
endmodule

program vpg2;
  int garr[2];
  class pgc2;
    int gaa[2];
    function void g_inc(int s);              gaa[s]++;            endfunction
  endclass
  function void gf_inc(int s);               garr[s]++;           endfunction
  pgc2 h;
  initial begin
    h = new();
    h.g_inc(0); gf_inc(1);
  end
endprogram

interface vif2;
  int iarr[2];
  class ifc2;
    int faa[2];
    function void if_inc(int s);             faa[s]++;            endfunction
  endclass
  function void iff_inc(int s);              iarr[s]++;           endfunction
endinterface

module vm2b;
  vif2 u_if();
endmodule
