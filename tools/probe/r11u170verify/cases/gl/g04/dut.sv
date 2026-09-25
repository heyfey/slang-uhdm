// § genCaLhsEnumConstClone158
typedef enum int { E_LO = 1, E_HI = 3 } e_t;
module top (input logic [3:0] a [2], output logic [7:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : GI
    assign o[i][E_HI:E_LO] = a[i][2:0];
  end
endmodule
