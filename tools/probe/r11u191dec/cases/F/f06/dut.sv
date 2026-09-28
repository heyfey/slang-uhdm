// (r11u191 N0215) an interface function and a package task with a ternary default over an enum
package r;
  typedef enum { R0, R1, R2 } k_t;
  task automatic tk(k_t k, int v = (k == R1) ? 10 : 20);
  endtask
endpackage
interface ifc;
  function automatic int g(int a, int b = a - 3);
    return a + b;
  endfunction
endinterface
module top;
  ifc u();
endmodule
