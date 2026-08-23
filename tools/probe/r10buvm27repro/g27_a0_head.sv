// r10buvm27 — THE 76-LINE BuildUVMPkg HEAD IN 34 LINES.
// uvm_pkg.sv:58066, uvm_tlm_generic_payload::do_compare:
//   void'(comparer.compare_field_int(name, m_data[i] & be,
//                                    gp.m_data[i] & be,
//                                    $bits(m_data[i] & be), UVM_HEX));
// with `rand byte unsigned m_data[]` and a local `byte unsigned be`.
// GOLDEN folds the FOURTH argument to a constant UINT:8 (vpiDecompile 8,
// vpiSize 64, vpiConstType 9) at the $bits text span; pristine keeps the
// sys_func_call over the vpiOpType 28 operation.
package h27_pkg;
  typedef enum int { H27_HEX = 16 } h27_radix_e;

  class h27_comparer;
    int result;
    function bit compare_field_int(string name, longint unsigned lhs,
                                   longint unsigned rhs, int size,
                                   h27_radix_e radix);
      return (lhs == rhs) && (size > 0) && (radix == H27_HEX);
    endfunction
  endclass

  class h27_payload;
    rand byte unsigned m_data [];
    int                m_length;

    function bit do_compare(h27_payload gp, h27_comparer comparer);
      byte unsigned be;
      for (int i = 0; i < m_length && i < m_data.size(); i++) begin
        be = 8'hFF;
        begin
          string name = "m_data";
          void'(comparer.compare_field_int(name, m_data[i] & be,
                                           gp.m_data[i] & be,
                                           $bits(m_data[i] & be), H27_HEX));
        end
      end
      return (comparer.result == 0);
    endfunction
  endclass
endpackage

module h27_top;
  import h27_pkg::*;
  initial begin
    h27_payload p = new();
    h27_comparer c = new();
    void'(p.do_compare(p, c));
  end
endmodule
