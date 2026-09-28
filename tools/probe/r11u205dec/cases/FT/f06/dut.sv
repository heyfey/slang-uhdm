// r11u205 FT f06: a module function formal typed by a module-local `typedef int`
module dut(output int o);
  typedef int act_t;
  function automatic int f(input act_t a);
    return a + 1;
  endfunction
  assign o = f(3);
endmodule
