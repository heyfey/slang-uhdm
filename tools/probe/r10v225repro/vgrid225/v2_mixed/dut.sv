// r10v225 arm v2_mixed — MIXED unpacked chains, every order.  The hook must
// keep ONE range per WRITTEN level, in written order, and never stop early.
// (Atom typedefs live INSIDE the component: a `$unit`-scope `typedef int` is a
// standing reject, r10uvm225 R6.)
interface if225v_mix();
  typedef logic [7:0] tvm_t;
  typedef int tim_t;
  tvm_t m_ff   [1:0][2];
  tvm_t m_fd   [1:0][];
  tvm_t m_df   [][1:0];
  tvm_t m_fq   [1:0][$];
  tvm_t m_qf   [$][1:0];
  tvm_t m_fa   [1:0][string];
  tvm_t m_af   [string][1:0];
  tvm_t m_dd   [][];
  tvm_t m_aa   [string][int];
  tvm_t m_an   [string][tim_t];
  tvm_t m_na   [tim_t][string];
  tvm_t m_qa   [$][string];
  tvm_t m_aq   [string][$];
  tvm_t m_3    [1:0][2][3];
  tvm_t m_4    [string][][$][1:0];
  tvm_t m_wf   [*];
endinterface

module top225v_mix(); endmodule
