// § genCaLhsEnumConstClone158 § sizeCastCaLitMask158
typedef enum int { E_LO = 1, E_HI = 3 } e_t;
module top (output logic [7:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : GI
    assign o[i][E_HI:E_LO] = 2'(7);
  end
endmodule
