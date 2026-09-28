// r11u205 FT f02: the same formal as an INPUT
package p;
  typedef int act_t;
  function automatic int f(input act_t a);
    return a + 1;
  endfunction
endpackage
module dut(output int o);
  assign o = p::f(3);
endmodule
