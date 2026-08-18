module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule

module mid #(parameter int K = 0);
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    sink #(8) u (.i_value(IV));
  end
endmodule
module top;
  mid #(.K(0)) m0 ();
  mid #(.K(1)) m1 ();
endmodule
