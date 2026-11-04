// § defNetTypeParamPackedDim144
typedef struct packed {
  logic [3:0] op;
  logic [7:0] a;
} d_t;
module top #(parameter type dtype = d_t) (output logic [63:0] sum);
    dtype [3:0] mem;
    dtype [5:0] mem2;
    assign mem = '0;
    assign mem2 = '0;
    assign sum = mem[0].a + mem2[1].a;
endmodule
