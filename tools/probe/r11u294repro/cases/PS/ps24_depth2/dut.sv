// § paramInitMemberSelLvShape294
// instance depth 2 with a pass-down override
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; logic [1:0][3:0] m; } c_t;
  localparam c_t C = '{u: 8'h35, d: 8'hA6, m: 8'h21};
endpackage
module kid #(parameter pk::c_t CFG = pk::C) (output logic o);
  localparam logic B = CFG.d[5];
  assign o = B;
endmodule
module mid #(parameter pk::c_t MC = pk::C) (output logic o); kid #(.CFG(MC)) k (.o(o)); endmodule
module dut(output logic o); mid m0 (.o(o)); endmodule
