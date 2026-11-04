// § tpEnumCopyAtTypedef184: a compilation-unit enum typedef as the top module's type parameter default
typedef enum logic [1:0] {U0, U1} u_e;
module top #(parameter type T = u_e) (input T si);
endmodule
