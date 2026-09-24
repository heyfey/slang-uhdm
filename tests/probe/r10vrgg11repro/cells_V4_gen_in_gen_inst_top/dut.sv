module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule

module mid;
  if (1) begin : gm
    localparam bit [7:0] IV = 8'hab;
    sink #(8) u (.i_value(IV));
  end
endmodule
module top;
  for (genvar gi = 0; gi < 2; gi++) begin : g
    mid m ();
  end
endmodule
