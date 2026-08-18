
module sinkr (input real i_value);
endmodule
module top;
  if (1) begin : g
    localparam real IV = 1.5;
    sinkr u (.i_value(IV));
  end
endmodule
