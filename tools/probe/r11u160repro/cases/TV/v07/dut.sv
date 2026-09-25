// § defNetTypeParamPackedVec160
typedef enum logic [1:0] {A, B, C} e_t;
module top #(parameter type dtype = e_t) (input logic clk, output logic [7:0] o);
  dtype [3:0] mem;
  always_ff @(posedge clk) mem <= {A, B, C, A};
  assign o = mem;
endmodule
