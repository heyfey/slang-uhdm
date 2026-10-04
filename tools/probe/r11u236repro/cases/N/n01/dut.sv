// § namedCallArgFormalTs236 — pass 231 residue: a named-argument call to a function with typedef formals
package p;
  typedef int UVM_FILE;
  typedef logic [7:0] byte_t;
endpackage
module top(input int a, input int b, output int o, output int o2);
  import p::*;
  function automatic int h(UVM_FILE x, byte_t y);
    return x + y;
  endfunction
  assign o = h(.y(b), .x(a));
  assign o2 = h(a, b);
endmodule
