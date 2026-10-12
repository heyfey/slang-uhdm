// § castPatTagKeyLocThroughParens302
// c11: the cast-pattern parameter's member in constant slots
package p;
  typedef struct packed { int unsigned n; int unsigned h; } cfg_t;
  localparam cfg_t C = cfg_t'('{n: 8, h: 2});
endpackage
module dut (input logic [15:0] i, output logic [7:0] o, output logic [3:0] q);
  logic [p::C.n-1:0] w;
  assign w = i[p::C.n-1:0];
  assign o = {p::C.h{w[3:0]}};
  assign q = i[p::C.h +: 4];
endmodule
