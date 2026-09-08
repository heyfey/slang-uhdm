// r10uvm208 arm E — THE MINIMISED CORPUS HEAD.  MiniAmiq's head at the base
// commit is
//
//   LHS bit_typespec (uvm_reg_addr_t)   parented at
//     ref_typespec: (svaunit_pkg::uvm_reg_map::m_set_reg_offset::addrs::uvm_reg_addr_t)
//   RHS bit_typespec (uvm_pkg::uvm_reg_addr_t)
//
// — uvm-1.2 `uvm_reg_model.svh:73` + `uvm_reg_map.svh:742-760`'s
// `uvm_reg_addr_t addrs[];` declared inside a `begin` block of an OUT-OF-BODY
// class method and walked by `foreach`, in the ELABORATED listing of a
// wildcard-importing package, where our emitter hands the SAME element chain to
// that clone declaration AND to the home body's foreach reference variable.
// Reduced here to a 64-bit package typedef, one class, one out-of-body method,
// one importer.
//
// PRISTINE: 112 cmp lines, ONE head, on
//   ref_typespec: (p208b_e::M208::m_set_reg_offset208::addrs208::uvm_reg_addr208_t)
// — the corpus head's exact shape and exact line count.
// PATCHED: 0 lines, 0 heads.  THE ARM CONVERTS.
package p208a_e;
  typedef bit [63:0] uvm_reg_addr208_t;
  class M208;
    extern function int m_set_reg_offset208(int off208);
  endclass
  function int M208::m_set_reg_offset208(int off208);
    int r208 = 0;
    begin
      uvm_reg_addr208_t addrs208[];
      foreach (addrs208[i208])
        r208 += int'(addrs208[i208]);
    end
    return r208 + off208;
  endfunction
endpackage

package p208b_e;
  import p208a_e::*;
  function automatic int ge208();
    M208 m208;
    m208 = new();
    return m208.m_set_reg_offset208(1);
  endfunction
endpackage

module g208_e_head;
  import p208b_e::*;
  int r208;
  initial r208 = ge208();
endmodule
