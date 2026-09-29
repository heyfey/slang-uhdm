// r11u220 decode (control): new[] size and call-argument names
package p;
class c;
  function int ceil(int a, int b); return (a+b-1)/b; endfunction
  function void f(int n_bytes, int bus_width);
    int local_addr[]; int x;
    x = ceil(n_bytes,bus_width);
  endfunction
endclass
endpackage
module top; endmodule
