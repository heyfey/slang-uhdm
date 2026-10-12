// § castPatTagKeyLocThroughParens302
// vc02: a cast-wrapped pattern with a default key only and a mixed member and default key
package p;
  typedef struct packed { int unsigned n; logic [15:0] h; } cfg_t;
  localparam cfg_t A = cfg_t'('{default: 9});
  localparam cfg_t B = cfg_t'('{n: 5, default: 16'h3});
endpackage
module dut (output logic [31:0] o);
  assign o = p::A.n + p::B.n;
endmodule
