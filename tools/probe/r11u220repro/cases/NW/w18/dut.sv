// § newArrayCallArgStripped220
package p;
class c;
  int k;
  function int ceil(int a, int b); return (a+b-1)/b; endfunction
  extern function void f(int n_bytes, int bus_width);
endclass
  function void c::f(int n_bytes, int bus_width);
    int d[];
    d = new[ceil(.a(n_bytes), .b(bus_width))];
  endfunction
endpackage
module top; endmodule
