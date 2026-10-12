// § castModTypeParamDefaultTs294
// pass-down of a type parameter two levels
module sub #(parameter type T = logic [7:0]) (input logic [3:0] a, output logic [7:0] y);
  always_comb y = T'(a);
endmodule
module mid #(parameter type T = logic [4:0]) (input logic [3:0] a, output logic [7:0] y); sub #(.T(T)) s (.a(a), .y(y)); endmodule
module top(input logic [3:0] a, output logic [7:0] y); mid m (.a(a), .y(y)); endmodule
