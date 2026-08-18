module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule

module mid #(parameter bit [7:0] K = 8'hab);
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    localparam bit [7:0] JV = K;
    sink #(8) u (.i_value(IV));
    sink #(8) v (.i_value(JV));
  end
endmodule
module top;
  mid #(.K(8'h01)) m0 ();
  mid #(.K(8'h02)) m1 ();
  mid #(.K(8'hab)) m2 ();
endmodule
