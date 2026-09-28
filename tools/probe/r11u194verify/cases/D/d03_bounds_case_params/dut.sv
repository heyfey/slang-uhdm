// § boundLitUnderscoreDropped186 § bareDecUnderscoreDropped181: range bounds 1_5 and 1_0, a size-form unpacked dimension [1_6] (v11u186's residue), a case item 1_0, parameter defaults 1_000_000 and a 65-bit decimal, a negative -1_0
module top #(parameter int P = 1_000_000, parameter logic [64:0] BIG = 36_893_488_147_419_103_231)
  (input logic [1_5:0] a, output logic [1_0:0] o, output int n);
  logic [3:0] m [1_6];
  logic [7:0] r [0:1_0];
  always_comb begin
    case (a)
      1_0: o = 11'd1_0;
      default: o = 11'd0;
    endcase
    n = -1_0;
  end
endmodule
