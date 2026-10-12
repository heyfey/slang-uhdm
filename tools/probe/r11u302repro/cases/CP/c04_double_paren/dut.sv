// § castPatTagKeyLocThroughParens302
// c04: doubled parentheses around the pattern
package p;
  typedef struct packed { int unsigned n; logic [15:0] h; } cfg_t;
  localparam cfg_t C = cfg_t'(('{n: 9, h: 16'h00AB}));
endpackage
module dut (output logic [31:0] o);
  assign o = p::C.n;
endmodule
