// r10sd9 GRID CELL g7 — NEGATIVE CONTROL and the pass's OWN REFUTATION CELL:
// the element type is a class TYPE PARAMETER, and a typedef OF that parameter
// sits next to it.  Golden spells the element with the typedef's name; the
// declared type is the parameter, so `sharedAliasTs` returns null and this
// pass provably cannot move it.  This is the corpus shape of
// uvm_sequencer_param_base's m_last_req_buffer / m_last_rsp_buffer.
package pt;
  class kt;
    int xt;
  endclass
  class ct #(type T = kt);
    typedef T t_type;
    T a_param [$];
    t_type a_alias [$];
  endclass
endpackage
module topt;
  pt::ct #(pt::kt) ht;
endmodule
