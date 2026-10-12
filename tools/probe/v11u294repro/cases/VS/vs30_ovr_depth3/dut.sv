// § paramInitMemberSelLvShape294
// an override passed down three instance levels
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; logic [1:0][3:0] m; } c_t;
  localparam c_t C = '{u: 8'h35, d: 8'hA6, m: 8'h21};
endpackage
module kid #(parameter pk::c_t CFG = pk::C) (output logic o);
  localparam logic B = CFG.d[3];
  assign o = B;
endmodule
module mid #(parameter pk::c_t P = pk::C) (output logic o); kid #(.CFG(P)) k (.o(o)); endmodule
module top2 #(parameter pk::c_t Q = pk::C) (output logic o); mid #(.P(Q)) m (.o(o)); endmodule
module dut(output logic o); top2 #(.Q('{u: 8'h11, d: 8'h0F, m: 8'h22})) t (.o(o)); endmodule
