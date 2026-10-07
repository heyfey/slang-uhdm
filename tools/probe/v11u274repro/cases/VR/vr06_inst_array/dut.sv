// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = 24'h010203) (output logic [7:0] o); assign o = P.u.a; endmodule
module dut(output logic [7:0] o [2]);
  kid #(.P(24'h040506)) k [1:0] (.o(o));
endmodule
