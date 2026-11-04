// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = 24'h010203) (input logic [7:0] x, output logic [7:0] o);
  function automatic logic [7:0] f(input logic [7:0] y); return y + P.u.a; endfunction
  always_comb o = f(x);
endmodule
module dut(input logic [7:0] x, output logic [7:0] o); kid k0 (.x(x), .o(o)); endmodule
