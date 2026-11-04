// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = 24'h010203) (output logic [7:0] o);
  if (P.u.a == 8'd1) begin : g
    always_comb o = P.u.b;
  end else begin : h
    always_comb o = P.d;
  end
endmodule
module dut(output logic [7:0] o, output logic [7:0] o2);
  kid k0 (.o(o));
  kid #(.P(24'h020304)) k1 (.o(o2));
endmodule
