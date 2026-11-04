// § cloneAliasCopyBareName484 (packed alias local and an alias of a struct holding a third-package struct member, two importers)
package s;
  typedef struct packed { logic [3:0] a; } in_t;
endpackage
package u;
  typedef struct packed { s::in_t i; logic [3:0] b; } op_t;
  typedef op_t op2_t;
  function logic [3:0] f(logic [7:0] n);
    op2_t acc;
    acc = n;
    return acc.i.a;
  endfunction
endpackage
package a;
  import u::*;
  function logic [3:0] g(); return f(8'h12); endfunction
endpackage
package b;
  import u::*;
  function logic [3:0] g2(); return f(8'h34); endfunction
endpackage
module top(output logic [3:0] o1, o2);
  import a::*;
  import b::*;
  assign o1 = g();
  assign o2 = g2();
endmodule
