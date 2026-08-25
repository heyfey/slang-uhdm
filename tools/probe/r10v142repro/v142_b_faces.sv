// r10v142 verifier arm B — FORWARD-DECLARED, INTERFACE CLASS, parameterized
// specialization, and the PROGRAM / INTERFACE homes, under both productions.
package pv2142;
  typedef class Fwd2142;
  interface class IFv2142;
    pure virtual function void go();
  endclass
  class Impl2142 implements IFv2142;
    virtual function void go();
    endfunction
  endclass
  class Fwd2142;
    int f;
  endclass
  class Gen2142 #(type Tv2142 = int, int Nv2142 = 1);
    Tv2142 g;
  endclass
  typedef Gen2142#(int, 2) tgen2142;

  function void ftf2142;
    Fwd2142           f_fwd;
    IFv2142           f_iface;
    Impl2142          f_impl;
    Gen2142#(int, 2)  f_spec;
    Gen2142           f_bare;
    tgen2142          f_tdspec;
  endfunction
  function void fbl2142();
    Fwd2142           b_fwd;
    IFv2142           b_iface;
    Impl2142          b_impl;
    Gen2142#(int, 2)  b_spec;
    Gen2142           b_bare;
    tgen2142          b_tdspec;
  endfunction
  // arrays / queues / assoc under the package-free TF-ITEM production
  function void atf2142;
    Fwd2142 a_arr [3];
    Fwd2142 a_q [$];
    Fwd2142 a_da [];
    Fwd2142 a_as [string];
    Fwd2142 a_m1, a_m2, a_m3;
  endfunction
  function void abl2142();
    Fwd2142 c_arr [3];
    Fwd2142 c_q [$];
    Fwd2142 c_da [];
    Fwd2142 c_as [string];
    Fwd2142 c_m1, c_m2, c_m3;
  endfunction
endpackage

program pv2prog142;
  import pv2142::*;
  function void ptf2142;
    Fwd2142 p_fwd;
  endfunction
  function void pbl2142();
    Fwd2142 pb_fwd;
  endfunction
  class Pcls2142;
    function void pctf;
      Fwd2142 pc_fwd;
    endfunction
    function void pcbl();
      Fwd2142 pcb_fwd;
    endfunction
  endclass
  initial begin
    ptf2142();
  end
endprogram

interface ifv2142;
  import pv2142::*;
  class Icls2142;
    int f;
  endclass
  function void itf2142;
    Fwd2142   i_fwd;
    Icls2142  i_same;
  endfunction
  function void ibl2142();
    Fwd2142   ib_fwd;
    Icls2142  ib_same;
  endfunction
endinterface
