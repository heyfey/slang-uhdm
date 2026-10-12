// § castPatTagKeyLocThroughParens302
// c10: the pattern written by a macro inside the cast
`define PAT '{n: 9, h: 16'h00AB}
package p;
  typedef struct packed { int unsigned n; logic [15:0] h; } cfg_t;
  localparam cfg_t C = cfg_t'(`PAT);
endpackage
module dut (output logic [31:0] o);
  assign o = p::C.n;
endmodule
