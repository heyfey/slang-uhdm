// r10uvm71 VERIFIER arm a3 -- EMPTY PRODUCT CELLS the implementer's a1/a2 leave
// unmeasured.  Each cell exercises a code path the patch touches or bypasses
// that a1/a2 never reach.
//
//  C1  ctor local whose TYPE contains $bits(<formal>)  -- the io_decl binder the
//      patch REWIRED (it used to read tf->Variables(), now reads the collected
//      vector).  a1/a2 contain no `$bits` at all.
//  C2  package class whose ctor local has a PACKAGE TYPEDEF type, wildcard-
//      imported into a module -- TypeEmit.cpp:6143 rebinds the typespecs of a
//      clone task_func's ->Variables(); a ctor no longer HAS one.
//  C3  EXTERN (out-of-body) ctor of a PARAMETERIZED class -- a1's oob cell is
//      unparameterized; a1's parameterized cell is in-body.  This is oob+clone.
//  C4  ctor with a QUEUE local (the uvm_objection `string trace_args[$]` shape:
//      one declaration -> TWO objects) and a dynamic-array local.
//  C5  class declared inside an INTERFACE.
//  C6  ctor local of a STRUCT typedef + a class-handle local (the uvm shape).
//  Controls: a non-ctor method carrying the SAME shapes in every cell.

package p3;

  typedef struct packed { logic [3:0] a; logic [3:0] b; } st3_t;
  typedef logic [7:0] byte3_t;

  // ---- C2 + C6: package class, ctor locals of package typedef types.
  class c_pkgtd;
    int m_i;
    function new(int v);
      st3_t    ctor_st;      // struct typedef local
      byte3_t  ctor_bt;      // scalar typedef local
      c_pkgtd  ctor_h;       // class-handle local (uvm shape)
      ctor_st = '0;
      ctor_bt = 8'(v);
      ctor_h  = null;
      m_i     = v + int'(ctor_bt);
    endfunction
    // CONTROL: same three shapes on a NON-constructor.  Must keep them.
    function int td_meth(int a);
      st3_t    meth_st;
      byte3_t  meth_bt;
      c_pkgtd  meth_h;
      meth_st = '0;
      meth_bt = 8'(a);
      meth_h  = null;
      return a + int'(meth_bt);
    endfunction
  endclass

  // ---- C3: EXTERN ctor of a PARAMETERIZED class.
  class c_oobpar #(int W = 8);
    int m_w;
    extern function new(int v);
    extern function int oobpar_meth(int a);
  endclass

  function c_oobpar::new(int v);
    int oobpar_ctor_loc;
    logic [W-1:0] oobpar_ctor_vec;
    oobpar_ctor_loc = v;
    oobpar_ctor_vec = '0;
    m_w = oobpar_ctor_loc;
  endfunction

  function int c_oobpar::oobpar_meth(int a);
    int oobpar_meth_loc;           // CONTROL
    oobpar_meth_loc = a;
    return oobpar_meth_loc;
  endfunction

  // ---- C4: QUEUE and DYNAMIC-ARRAY ctor locals (the trace_args shape).
  class c_queue;
    int m_q;
    function new(int v);
      string q_args[$];
      int    d_args[];
      q_args.push_back("x");
      d_args = new[2];
      m_q = v + q_args.size() + d_args.size();
    endfunction
    function int q_meth(int a);    // CONTROL: same shapes, non-ctor
      string qm_args[$];
      int    dm_args[];
      qm_args.push_back("y");
      dm_args = new[1];
      return a + qm_args.size() + dm_args.size();
    endfunction
  endclass

  // ---- C1: $bits(<formal>) inside a ctor LOCAL's type -- the rewired binder.
  class c_bits;
    int m_b;
    function new(input logic [5:0] a);
      logic [$bits(a)-1:0] ctor_vec;   // type mentions the FORMAL
      ctor_vec = a;
      m_b = int'(ctor_vec);
    endfunction
    // CONTROL: the identical $bits shape on a non-constructor.
    function int bits_meth(input logic [5:0] a);
      logic [$bits(a)-1:0] meth_vec;
      meth_vec = a;
      return int'(meth_vec);
    endfunction
  endclass

endpackage

// ---- C5: class declared inside an INTERFACE.
interface if3;
  class c_ifc;
    int m_c;
    function new(int v);
      int ifc_ctor_loc;
      ifc_ctor_loc = v;
      m_c = ifc_ctor_loc;
    endfunction
    function int ifc_meth(int a);   // CONTROL
      int ifc_meth_loc;
      ifc_meth_loc = a;
      return ifc_meth_loc;
    endfunction
  endclass
endinterface

module a3;
  import p3::*;                       // WILDCARD import -> the clone path

  c_pkgtd        h_td;
  c_oobpar #(4)  h_oobpar;
  c_queue        h_q;
  c_bits         h_bits;
  int            r;

  initial begin
    h_td     = new(1);
    h_oobpar = new(2);
    h_q      = new(3);
    h_bits   = new(6'h3f);
    r = h_td.td_meth(1) + h_oobpar.oobpar_meth(2) + h_q.q_meth(3)
      + h_bits.bits_meth(6'h0f);
  end
endmodule
