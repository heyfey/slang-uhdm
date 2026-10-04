// § namedCallArgFormalTs236 — named-argument call, typedef formals, actual names equal the formals
package p;
  typedef int UVM_FILE;
endpackage
module top(input int x, input int y, output int o);
  import p::*;
  function automatic int h(UVM_FILE x, UVM_FILE y);
    return x - y;
  endfunction
  assign o = h(.y(y), .x(x));
endmodule
