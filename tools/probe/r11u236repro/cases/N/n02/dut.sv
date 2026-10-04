// § caOpArgIntFormalTs236 — pass 231 CA c05: an operation argument beside a plain name (copy of r11u231repro/cases/CA/c05)
package p;
  typedef int UVM_FILE;
endpackage
module top(input int a, output int o, output int o2);
  import p::UVM_FILE;
  function automatic int h(UVM_FILE z, int k);
    return z + k;
  endfunction
  assign o = h(a, a);
  assign o2 = h(a, a + 1);
endmodule
