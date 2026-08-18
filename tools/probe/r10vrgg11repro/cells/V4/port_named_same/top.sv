
module sink #(parameter int W = 8) (input logic [W-1:0] IV);
endmodule
module top;
  if (1) begin : g
    localparam logic [7:0] IV = 8'hab;
    sink #(8) u (.IV);
  end
endmodule
