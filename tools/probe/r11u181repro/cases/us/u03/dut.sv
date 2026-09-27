// § bareDecUnderscoreDropped181 — underscores in parameter and localparam values and a range bound
module top #(parameter int P = 1_0) (output logic [1_5:0] o);
  localparam int L = 2_0;
  localparam logic [7:0] H = 8'hA_5;
  assign o = P + L + H;
endmodule
