// § defNetTypeParamPackedDim144
typedef struct packed {
  logic [3:0] op;
  logic [7:0] a;
} d_t;
module top #(parameter type dtype = d_t) (output logic [63:0] sum);
    dtype [3:0] m1, m2;
    assign m1 = '0;
    assign m2 = '0;
    assign sum = m1[0].a + m2[1].a;
endmodule
