// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = '0) (output logic [7:0] o);
  task automatic t(output logic [7:0] y); logic [7:0] P; P = 1; y = P; endtask
  function automatic logic [7:0] g(pk::c_t P); return P.u.a; endfunction
  always_comb begin logic [7:0] r; t(r); o = r + g(P) + P.u.b; end
endmodule
module dut(output logic [7:0] o); kid k0 (.o(o)); endmodule
