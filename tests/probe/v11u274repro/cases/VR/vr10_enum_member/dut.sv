// § elabMemberReadCopyChain274
package pk;
  typedef enum logic [1:0] {A0, A1, A2} e_t;
  typedef struct packed { e_t e; logic [5:0] v; } s_t;
  typedef struct packed { s_t s; logic [7:0] w; } c_t;
endpackage
module kid #(parameter pk::c_t P = '{s: '{e: pk::A2, v: 6'd3}, w: 8'd7}) (output logic [1:0] o, output logic b);
  assign o = P.s.e;
  always_comb b = (P.s.e == pk::A2);
endmodule
module dut(output logic [1:0] o, output logic b); kid k0 (.o(o), .b(b)); endmodule
