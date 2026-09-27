// § tpEnumCopyAtTypedef184: a compilation-unit enum typedef as a type parameter's default, instantiated without an override
typedef enum logic [1:0] {U0, U1} u_e;
module sub #(parameter type T = u_e) (input T si);
endmodule
module top();
  u_e p;
  sub v (.si(p));
endmodule
