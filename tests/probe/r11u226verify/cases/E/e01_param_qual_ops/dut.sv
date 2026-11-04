// § pkgQualOperandSpanInParam218 — package-qualified operands inside module parameter initializers: a sum, a shift, a product in parentheses, a unary minus
package cfg;
  localparam int A = 3;
  localparam int B = 5;
endpackage
module m #(parameter int P1 = cfg::A + 2*cfg::B,
           parameter int P2 = (cfg::A << 2) - 1,
           parameter int P3 = -cfg::B + (cfg::A * cfg::B))
  (output int o);
  assign o = P1 + P2 + P3;
endmodule
module top(output int o);
  m u(.o(o));
endmodule
