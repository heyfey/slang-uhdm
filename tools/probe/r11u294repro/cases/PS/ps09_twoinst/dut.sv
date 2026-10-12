// § paramInitMemberSelLvShape294
// two instances, one overriding the struct
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; logic [1:0][3:0] m; } c_t;
  localparam c_t C = '{u: 8'h35, d: 8'hA6, m: 8'h21};
endpackage
module kid #(parameter pk::c_t CFG = pk::C) (output logic o);
  localparam logic B = CFG.d[2];
  assign o = B;
endmodule
module dut(output logic o1, o2);
  kid k0 (.o(o1));
  kid #(.CFG('{u: 8'h0, d: 8'hFF, m: 8'h0})) k1 (.o(o2));
endmodule
