// r10uvm68 arm a5 — the SITES this pass might have to reach that arms a1-a3 do
// NOT exercise: a PURE VIRTUAL method's synthesized return var, a DPI-IMPORT
// prototype's synthesized return var, an EXTERN out-of-body method, a
// FORK/named-block local, an always_comb local, and a function whose return
// NAME is referenced in its own body (which is what makes drainFuncRet mint a
// per-reference body-local — § retLocalPkgRangeBind67's site).
// A site with no golden/ours disagreement must NOT be gated: an ungated site is
// a residue, a gated site with nothing to gate is dead code.
typedef int q_t;
package pk5;
  typedef int pq_t;
  function pq_t pkf();      // package function, return through a name
    pkf = 0;                // ... and the return NAME referenced in the body
  endfunction
endpackage

virtual class V5;
  pure virtual function q_t pv_ret();
  extern function q_t ex_ret();
endclass
function q_t V5::ex_ret();
  q_t ex_loc;
  ex_ret = ex_loc;
endfunction

module m5_mod;
  import "DPI-C" function q_t dpi_ret(input int x);
  q_t m_wr_named;
  function q_t selfref();
    selfref = 1;            // return NAME referenced -> drainFuncRet local
  endfunction
  always_comb begin
    q_t ac_loc;
    m_wr_named = ac_loc;
  end
  initial begin : nb5
    q_t nb_loc = 3;
    fork
      begin : fk5
        q_t fk_loc = 4;
        nb_loc = fk_loc;
      end
    join_none
    nb_loc = selfref() + pk5::pkf() + dpi_ret(1);
  end
endmodule
