// § castPatTagKeyLocThroughParens302
// c07: CONTROL - a typed pattern (no parentheses) and a bare one
package p;
  typedef struct packed { int unsigned n; logic [15:0] h; } cfg_t;
  localparam cfg_t T = cfg_t'{n: 7, h: 16'h8};
  localparam cfg_t B = '{n: 9, h: 16'h9};
endpackage
module dut (output logic [31:0] o);
  assign o = p::T.n + p::B.n;
endmodule
