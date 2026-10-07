// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = '0, parameter bit EN = 1) (output logic [7:0] o);
  if (EN) begin : g
    assign o = P.u.a;
  end else begin : h
    assign o = P.d;
  end
endmodule
module dut(output logic [7:0] o, output logic [7:0] o2);
  kid k0 (.o(o));
  kid #(.P(24'h010203), .EN(0)) k1 (.o(o2));
endmodule
