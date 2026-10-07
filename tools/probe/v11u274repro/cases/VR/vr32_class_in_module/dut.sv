// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = 24'h010203) (output logic [7:0] o);
  class cc;
    function logic [7:0] g(); return P.u.a; endfunction
  endclass
  initial begin cc x = new; o = x.g(); end
endmodule
module dut(output logic [7:0] o); kid k0 (.o(o)); endmodule
