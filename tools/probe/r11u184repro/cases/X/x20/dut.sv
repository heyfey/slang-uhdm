// § tpEnumCopyAtTypedef184: a compilation-unit enum typedef passed as a type parameter override
typedef enum logic [1:0] {U0, U1} u_e;
module sub #(parameter type T = logic) (input T si);
endmodule
module top();
  u_e p;
  sub #(.T(u_e)) v (.si(p));
endmodule
