// UVM_MS_IMP_COMMON shape: a CONDITION on a handle whose type is an
// unspecialized type parameter defaulting to `int` -- slang rejects the
// condition and drops the WHOLE if-statement.
package p2;
  class msc #(type IMP = int, type RQ = int, type RS = int);
    local RQ m_req_imp;
    local RS m_rsp_imp;
    int m_if_mask;
    function new(string name, IMP imp, RQ req_imp = null, RS rsp_imp = null);
      if (req_imp == null) $cast(req_imp, imp);       // A: if + system call
      if (rsp_imp != null) m_rsp_imp = rsp_imp;       // B: if + assignment
      m_req_imp = req_imp;                            // C: plain assignment
      m_if_mask = 3;
    endfunction
    function bit chk(RQ a);
      if (a == null) return 0;                        // D: if + return
      return 1;
    endfunction
    function void two(RQ a);
      if (a == null) begin                            // E: if + block
        m_if_mask = 1;
        m_if_mask = 2;
      end
      else
        m_if_mask = 4;                                // F: else arm
    endfunction
  endclass
endpackage

module top;
  import p2::*;
  initial;
endmodule
