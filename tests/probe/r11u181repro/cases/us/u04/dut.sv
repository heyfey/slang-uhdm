// § bareDecUnderscoreDropped181 — underscores in procedural assignments, a case item and a cast size
module top(input logic [7:0] s, output logic [15:0] y);
  always_comb begin
    y = 1_0;
    case (s)
      1_2: y = 16'd3_3;
      default: y[7:0] = 4_4;
    endcase
    y = y + 16'(1_1);
  end
endmodule
