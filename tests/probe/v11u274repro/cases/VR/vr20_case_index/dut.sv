// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = 24'h010203) (input logic [7:0] x, output logic o);
  always_comb begin
    case (x)
      P.u.a: o = 1'b1;
      P.u.b: o = 1'b0;
      default: o = x[P.d[2:0]];
    endcase
  end
endmodule
module dut(input logic [7:0] x, output logic o); kid k0 (.x(x), .o(o)); endmodule
