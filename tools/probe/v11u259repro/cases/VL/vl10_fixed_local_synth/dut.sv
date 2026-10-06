// § cloneLoopVarHomeDeclTs259 (a synthesizable function with a fixed local array of the typedef, called from a module)
package p;
  typedef logic [3:0] n_t;
  function automatic logic [3:0] f(input logic [3:0] a);
    n_t arr [2];
    logic [3:0] s;
    s = 0;
    arr[0] = a; arr[1] = ~a;
    foreach (arr[i])
      s = s ^ arr[i];
    return s;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top(input logic [3:0] a, output logic [3:0] y);
  import p::*;
  assign y = f(a);
endmodule
