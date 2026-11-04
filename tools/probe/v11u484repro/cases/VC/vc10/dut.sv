// § cloneAliasCopyBareName484 (union alias of an alias in a clone)
package u;
  typedef union packed { logic [7:0] r; logic [7:0] q; } un_t;
  typedef un_t un2_t;
  typedef un2_t un3_t;
  function logic [7:0] f(logic [7:0] n);
    un3_t acc;
    acc.r = n;
    return acc.q;
  endfunction
endpackage
package a;
  import u::*;
  function logic [7:0] g(); return f(8'h5); endfunction
endpackage
module top(output logic [7:0] o);
  import a::*;
  assign o = g();
endmodule
