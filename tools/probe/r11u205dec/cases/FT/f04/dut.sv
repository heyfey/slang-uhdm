// r11u205 FT f04: a package `typedef bit` formal
package p;
  typedef bit flag_t;
  function automatic flag_t f(input flag_t a);
    return !a;
  endfunction
endpackage
module dut(output logic o);
  assign o = p::f(1'b0);
endmodule
