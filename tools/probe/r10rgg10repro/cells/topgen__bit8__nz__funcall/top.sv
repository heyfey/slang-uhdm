module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule
module top;
  generate if (1) begin : g
  localparam bit [7:0] IV = 8'hab;
  function automatic logic [7:0] f(input logic [7:0] a);
  f = a;
endfunction
  wire [7:0] w; assign w = f(IV);
  end endgenerate
endmodule
