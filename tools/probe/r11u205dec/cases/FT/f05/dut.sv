// r11u205 FT f05: two functions with formals of the same package `typedef int`
package p;
  typedef int act_t;
  function automatic int f(input act_t a);
    return a + 1;
  endfunction
  function automatic int g(input act_t b, input act_t c);
    return b + c;
  endfunction
endpackage
module dut(output int o);
  assign o = p::f(3) + p::g(1, 2);
endmodule
