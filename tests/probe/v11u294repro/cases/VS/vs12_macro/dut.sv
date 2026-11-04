// § paramInitMemberSelLvShape294
// the select from a macro
`define SEL(x) x.d[0]
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; logic [1:0][3:0] m; } c_t;
  localparam c_t C = '{u: 8'h35, d: 8'hA6, m: 8'h21};
endpackage
module kid #(parameter pk::c_t CFG = pk::C) (output logic [7:0] o);
  localparam logic B = `SEL(CFG);
  assign o = B;
endmodule
module dut(output logic [7:0] o); kid k0 (.o(o)); endmodule
