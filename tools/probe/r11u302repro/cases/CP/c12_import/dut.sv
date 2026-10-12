// § castPatTagKeyLocThroughParens302
// c12: imported into the module
package p;
  typedef struct packed { int unsigned n; logic [15:0] h; } cfg_t;
  localparam cfg_t C = cfg_t'('{n: 9, h: 16'h00AB});
endpackage
module dut import p::*; (output logic [31:0] o);
  assign o = C.n;
endmodule
