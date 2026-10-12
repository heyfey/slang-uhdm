// § castPatTagKeyLocThroughParens302
// vc10: a cast-wrapped pattern as a class specialization's parameter, read in a part-select bound
package p;
  typedef struct packed { int unsigned n; int unsigned h; } cfg_t;
  class C #(parameter cfg_t P = cfg_t'('{n: 1, h: 0}));
    localparam int unsigned W = P.n;
  endclass
endpackage
module dut (input logic [31:0] i, output logic [7:0] o);
  assign o = i[p::C#(p::cfg_t'('{n: 7, h: 0}))::W -: 8];
endmodule
