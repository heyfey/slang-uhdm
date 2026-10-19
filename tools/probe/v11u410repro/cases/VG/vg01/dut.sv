// § genLpUntypedDefNoTs410
module top #(parameter W = 4) (input logic [W-1:0] a, output logic [W-1:0] y);
  if (W > 2) begin : g
    localparam S = "abc";
    assign y = a;
  end
endmodule
