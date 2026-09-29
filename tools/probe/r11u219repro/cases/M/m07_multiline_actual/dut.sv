// § ppIdentEndInRebuiltText219 — an actual written over two lines at the invocation site, forwarded through a second macro
`define INNER(OBJ, METHOD) \
  begin \
    $display("x"); \
    OBJ.METHOD; \
  end
`define OUTER(OBJ, METHOD) \
  `INNER(OBJ, METHOD)
package p;
class c;
  function void two(int a, int b); endfunction
  function void run(int x);
    `OUTER(this, two(x,
                     x + 1))
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
