// § castPatTagKeyLocThroughParens302
// vc04: a cast-wrapped pattern on an unpacked struct in a module localparam
module dut (output logic [31:0] o);
  typedef struct { int unsigned n; logic [15:0] h; } ucfg_t;
  localparam ucfg_t U = ucfg_t'('{n: 9, h: 16'h00AB});
  assign o = U.n;
endmodule
