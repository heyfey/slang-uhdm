// § castPatTagKeyLocThroughParens302
// vc08: the cast-wrapped pattern comes from a macro argument; the keys from the macro body
package p;
  typedef struct packed { int unsigned n; logic [15:0] h; } cfg_t;
endpackage
`define MKC(V) p::cfg_t'('{n: V, h: 16'h1})
`define MKP(PAT) p::cfg_t'(PAT)
module dut (output logic [31:0] o);
  localparam p::cfg_t A = `MKC(5);
  localparam p::cfg_t B = `MKP('{n: 6, h: 16'h2});
  assign o = A.n + B.n;
endmodule
