module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule

module top;
  if (1) begin : a
    if (1) begin : b
      if (1) begin : c
        localparam bit [7:0] IV = 8'hab;
        sink #(8) u (.i_value(IV));
      end
    end
  end
endmodule
