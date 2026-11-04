// § aliasTdTargetTopView484 (package alias never imported, only declared with a function local)
package u;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  typedef op_t op2_t;
  function automatic logic [3:0] f(logic [7:0] n);
    op2_t w;
    w = n;
    return w.a;
  endfunction
endpackage
module top(input logic [7:0] i, output logic [3:0] o);
  assign o = i[3:0];
endmodule
