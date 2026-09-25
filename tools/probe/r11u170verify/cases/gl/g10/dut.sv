// § genCaLhsEnumConstClone158
typedef enum logic [2:0] { K1 = 3'd1, K5 = 3'd5 } k_t;
module top #(parameter bit EN = 1) (input logic [7:0] a, output logic [7:0] o, output logic p);
  if (EN) begin : B
    assign o[K5] = a[K1];
    assign p = a[K5];
  end
endmodule
