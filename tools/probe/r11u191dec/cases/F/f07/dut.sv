// (r11u191 N0215) controls: literal and lone-name defaults (no joined name below the io_decl) and a unary default
package s;
  function automatic int f(int a, int b = 3, string c = "x", int d = a, int e = -a);
    return a;
  endfunction
endpackage
module top; endmodule
