// § newArrayCallArgStripped220
package p;
class c;
  function int ceil(int a, int b); return (a+b-1)/b; endfunction
  function void f(int n_bytes, int bus_width);
    int local_addr[]; int x;
    local_addr = new[ceil(n_bytes,bus_width)](local_addr);
  endfunction
endclass
endpackage
module top; endmodule
