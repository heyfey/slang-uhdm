// § castPatTagKeyLocThroughParens302
// c06: a cast-wrapped pattern with a default key
package p;
  typedef struct packed { int unsigned n; logic [15:0] h; } cfg_t;
  localparam cfg_t C = cfg_t'('{n: 4, default: 0});
endpackage
module dut (output logic [31:0] o);
  assign o = p::C.n;
endmodule
