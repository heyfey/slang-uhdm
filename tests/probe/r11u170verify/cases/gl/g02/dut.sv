// § genCaLhsEnumConstClone158
module top (input logic a, output logic [7:0] o);
  typedef enum int { E_A = 2, E_B = 5 } e_t;
  for (genvar i = 0; i < 2; i++) begin : G
    assign o[E_A + i] = a;
    assign o[E_B + i] = ~a;
  end
endmodule
