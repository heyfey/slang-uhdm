// r10uvm205 arm E — THE MINIMISED CORPUS HEAD.  uvm-1.2
// `uvm_reg_model.svh:73` + `uvm_reg.svh:1767-1771` reduced to a package
// typedef `bit [63:0] t`, a class with an OUT-OF-BODY method whose only local
// is `t addr[];`, and a package that wildcard-imports it.
package p205a_h;
  typedef bit [63:0] uvm_reg_addr205_t;
  class R205;
    extern function uvm_reg_addr205_t get_address205();
    extern function int get_addresses205(ref uvm_reg_addr205_t a205[]);
  endclass
  function uvm_reg_addr205_t R205::get_address205();
    uvm_reg_addr205_t addr205[];
    void'(get_addresses205(addr205));
    return addr205[0];
  endfunction
  function int R205::get_addresses205(ref uvm_reg_addr205_t a205[]);
    a205 = new[1];
    return 1;
  endfunction
endpackage

package p205b_h;
  import p205a_h::*;
  function automatic uvm_reg_addr205_t gh205();
    R205 r205;
    r205 = new();
    return r205.get_address205();
  endfunction
endpackage

module g205_e_head;
  import p205b_h::*;
  bit [63:0] r205;
  initial r205 = gh205();
endmodule
