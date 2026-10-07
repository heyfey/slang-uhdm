// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = 24'h010203) (input logic [7:0] x, output logic [7:0] o);
  logic [7:0] m [4];
  always_comb begin
    for (int i = 0; i < 4; i++) m[i] = '0;
    m[P.u.a[1:0]] = x;
    o = m[P.u.b[1:0]];
  end
endmodule
module dut(input logic [7:0] x, output logic [7:0] o); kid k0 (.x(x), .o(o)); endmodule
