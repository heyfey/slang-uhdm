// § castPatTagKeyLocThroughParens302
// c03: a header parameter default and an override, both cast-wrapped
typedef struct packed { int unsigned n; logic [15:0] h; } cfg_t;
module kid #(parameter cfg_t P = cfg_t'('{n: 1, h: 16'h2})) (output logic [31:0] o);
  assign o = P.n;
endmodule
module dut (output logic [31:0] o, output logic [31:0] q);
  kid k0 (.o(o));
  kid #(.P(cfg_t'('{n: 5, h: 16'h6}))) k1 (.o(q));
endmodule
