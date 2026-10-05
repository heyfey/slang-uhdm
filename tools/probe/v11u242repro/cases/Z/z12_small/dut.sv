// § signCastLitLeftoverIsBodyOperand242
// A small struct of int members built by a function with an unsigned'(literal) member and an integer formal, no wide member.
package cp;
  typedef struct packed { int unsigned a; int unsigned k; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t r;
    r.a = x;
    r.k = unsigned'(7);
    return r;
  endfunction
endpackage
module top #(parameter cp::cfg_t C = cp::build(3)) (output logic [31:0] o);
  assign o = C.k;
endmodule
