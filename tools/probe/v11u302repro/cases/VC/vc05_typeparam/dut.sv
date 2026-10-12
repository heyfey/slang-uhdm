// § castPatTagKeyLocThroughParens302
// vc05: a cast to a type parameter wrapping a pattern, inside an always_comb and a port actual
package p;
  typedef struct packed { int unsigned n; logic [15:0] h; } cfg_t;
endpackage
module kid (input p::cfg_t i, output logic [31:0] o);
  assign o = i.n;
endmodule
module dut #(parameter type T = p::cfg_t) (output logic [31:0] o, o2);
  T v;
  always_comb v = T'('{n: 3, h: 16'h7});
  kid u (.i(T'('{n: 4, h: 16'h8})), .o(o2));
  assign o = v.n;
endmodule
