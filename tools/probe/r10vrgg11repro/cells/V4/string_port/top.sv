
module sinks (input string i_value);
endmodule
module top;
  if (1) begin : g
    localparam string IV = "ab";
    sinks u (.i_value(IV));
  end
endmodule
