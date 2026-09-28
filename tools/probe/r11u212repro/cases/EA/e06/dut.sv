// § pkgEnumAliasListingParent212 — a package alias used as a class method formal (extern prototype and out-of-block body, uvm_sequencer_base::set_arbitration's shape)
package p;
  typedef enum { A, B, C } e_t;
  typedef e_t f_t;
  class c;
    f_t m;
    extern function void set(f_t val);
  endclass
  function void c::set(f_t val); m = val; endfunction
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
