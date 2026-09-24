// § defNetTypeParamPackedDim144
typedef enum logic [1:0] {A, B, C} e_t;
module top #(parameter type dtype = e_t) (output logic [63:0] sum);
    dtype [3:0] mem;
    assign mem = '0;
    assign sum = mem[0];
endmodule
