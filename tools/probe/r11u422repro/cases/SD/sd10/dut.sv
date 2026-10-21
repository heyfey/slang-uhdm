// § strNetRefMintsNet422
module top(input d, g, output o);
  trireg (large) c;
  if (1) begin : gb
    assign o = c;
  end
endmodule
