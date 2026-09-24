// § elabPatQualRefQualSpan133
// case pq02: nested-struct pattern parameter, qualified default, sub-module
package np;
  typedef struct packed { int unsigned A; int unsigned B; } in_t;
  typedef struct packed { in_t I; bit F; } out_t;
  localparam out_t Def = '{I: '{A: 3, B: 5}, F: 1'b0};
endpackage
module sub #(parameter np::out_t P = np::Def) (output logic [31:0] o);
  assign o = P.I.B;
endmodule
module top(output logic [31:0] o); sub u(.o(o)); endmodule
