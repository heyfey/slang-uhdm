// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = 24'h010203) (output logic [7:0] o, output logic [7:0] o2);
  function automatic logic [7:0] f(pk::c_t P); return P.u.a; endfunction
  function automatic logic [7:0] g(); return P.u.b; endfunction
  assign o = f(24'h0);
  assign o2 = g();
endmodule
module dut(output logic [7:0] o, output logic [7:0] o2); kid k0 (.o(o), .o2(o2)); endmodule
