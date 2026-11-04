// § aliasTdTargetTopView484 (package alias of a union of another package)
package s;
  typedef union packed { logic [7:0] r; logic [7:0] q; } un_t;
endpackage
package u;
  import s::*;
  typedef un_t un2_t;
  function automatic logic [7:0] f(logic [7:0] n);
    un2_t a;
    a.r = n;
    return a.q;
  endfunction
endpackage
module top(input logic [7:0] i, output logic [7:0] o);
  assign o = u::f(i);
endmodule
