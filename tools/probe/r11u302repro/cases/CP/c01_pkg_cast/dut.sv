// § castPatTagKeyLocThroughParens302
// c01: the package localparam's cast-wrapped pattern beside a bare one (vv1c's shape)
package p;
  typedef struct packed { int unsigned n; logic [15:0] h; } cfg_t;
  localparam cfg_t CAST  = cfg_t'('{n: 9, h: 16'h00AB});
  localparam cfg_t NAMED = '{n: 12, h: 16'h00CD};
endpackage
module dut (output logic [31:0] o);
  assign o = p::CAST.n + p::NAMED.n;
endmodule
