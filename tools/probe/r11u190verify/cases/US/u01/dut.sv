// § bareDecUnderscoreDropped181 § bigDecUnderscoreDropped181v (r11u190: 1_000_000 and 1_0 in parameter defaults and a localparam expression, a range bound, a 67-bit decimal)
module top #(parameter int P = 1_000_000, parameter int Q = 1_0) (output logic [1_5:0] r, output logic [31:0] s);
  localparam int R = Q * 1_0 + 2_5;
  localparam logic [69:0] BIG = 100_000_000_000_000_000_000;
  assign r = R;
  assign s = P + BIG[31:0];
endmodule
