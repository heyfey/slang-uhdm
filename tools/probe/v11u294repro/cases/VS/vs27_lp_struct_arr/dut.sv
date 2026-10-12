// § paramInitMemberSelLvShape294
// a localparam struct and a select on a two-dimensional member
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; logic [1:0][3:0] m; } c_t;
  localparam c_t C = '{u: 8'h35, d: 8'hA6, m: 8'h21};
endpackage
module kid #(parameter pk::c_t CFG = pk::C) (output logic [3:0] o, output logic p);
  localparam logic [3:0] B = CFG.m[0];
  localparam logic E = CFG.u[3];
  assign o = B;
  assign p = E;
endmodule
module dut(output logic [3:0] o, output logic p); kid k0 (.o(o), .p(p)); endmodule
