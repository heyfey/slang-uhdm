// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
class cp #(parameter pk::c_t P = 24'h010203);
  static function logic [7:0] g(); return P.u.b; endfunction
endclass
module dut(output logic [7:0] o); initial o = cp#(24'h0a0b0c)::g(); endmodule
