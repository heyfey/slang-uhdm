// r10uvm98 arm a1 — THE HEAD, MINIMISED.  An INHERITED typedef name written in
// a DERIVED class body vs the SAME name written in the DECLARING class body,
// with a THIRD, alphabetically EARLIER class also declaring the name.
package p98a;
  class aaa98 #(type T = int);            // alphabetically FIRST in p98a
    typedef aaa98 #(T) this_type;
    typedef int my_t;
    function void own_a(this_type prov); endfunction
  endclass

  class bbb98 #(type IF = int);
    typedef bbb98 #(IF) this_type;        // the SECOND declarer of `this_type`
    typedef bit my_t;                     // the SECOND declarer of `my_t`
    function void own_b(this_type prov); endfunction   // OWN name, resolves
    my_t own_m;
  endclass

  class ccc98 extends bbb98 #(int);       // DERIVED: writes the INHERITED names
    function void inh_formal(this_type prov); endfunction
    my_t inh_prop;
    function this_type inh_ret(); return null; endfunction
    task inh_local(); this_type lv; my_t lm; endtask
  endclass
endpackage

module top98a;
  import p98a::*;
  aaa98 #(int) ha;
  bbb98 #(int) hb;
  ccc98 hc;
  initial begin ha = new(); hb = new(); hc = new(); end
endmodule
