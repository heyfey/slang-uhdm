// r10buvm29 arm F — THE HEAD, MINIMISED.  uvm_pkg.sv:58249 is
// `m_command = uvm_tlm_command_e'({ << bit { __array }});` inside the
// OUT-OF-BLOCK class method `uvm_tlm_generic_payload::do_unpack` of package
// uvm_pkg, expanded from `uvm_packer_defines.svh:211`'s
// `VAR = TYPE'({ << bit { __array }}); \`.
package f29;
  typedef enum { UVM_TLM_READ_COMMAND, UVM_TLM_WRITE_COMMAND } tlm_command_e;
  class gp;
    tlm_command_e m_command;
    extern function void do_unpack();
  endclass
  function void gp::do_unpack();
    bit __array[];
    m_command = tlm_command_e'({ << bit { __array }});
  endfunction
endpackage
