// § tpEnumCopyAtTypedef184: the enum type re-passed a level down through another type parameter (both copies parented)
module leaf #(parameter type U = logic) (input U li);
endmodule
module mid #(parameter type T = logic) (input T mi);
  leaf #(.U(T)) l (.li(mi));
endmodule
module top(input logic [1:0] a);
  typedef enum logic [1:0] {K0, K1} k_e;
  k_e x;
  assign x = k_e'(a);
  mid #(.T(k_e)) m (.mi(x));
endmodule
