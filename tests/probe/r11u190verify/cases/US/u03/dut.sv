// § bareDecUnderscoreDropped181 (r11u190: case items and an enum value with separators; the enum face is the sister ground's)
module top(input int x, output logic [3:0] y);
  typedef enum int {E0 = 0, E1 = 1_0, E2 = 2_0} e_t;
  e_t e;
  always_comb begin
    e = E1;
    case (x)
      1_0: y = 4'd1;
      2_0, 3_0: y = 4'd2;
      default: y = 4'd0;
    endcase
  end
endmodule
