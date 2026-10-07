// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = '0) (input logic [7:0] x, output logic [7:0] o);
  always_comb begin
    o = x[P.u.a[2:0]] ? P.u.b : P.d;
    o[P.u.a[2:0] +: 2] = 2'b0;
  end
endmodule
module dut(input logic [7:0] x, output logic [7:0] o, o2);
  kid k0 (.x(x), .o(o));
  kid #(.P(24'h010203)) k1 (.x(x), .o(o2));
endmodule
