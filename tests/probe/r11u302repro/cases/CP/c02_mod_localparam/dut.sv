// § castPatTagKeyLocThroughParens302
// c02: a module localparam with a cast-wrapped pattern
typedef struct packed { int unsigned n; logic [15:0] h; } cfg_t;
module dut (output logic [31:0] o);
  localparam cfg_t C = cfg_t'('{n: 3, h: 16'h1});
  assign o = C.n;
endmodule
