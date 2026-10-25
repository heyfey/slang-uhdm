// § oneBitXQuirkTokenOnly427
module top(input logic clk, output logic r, output logic s);
  always_ff @(posedge clk) begin
    r <= 1'hx;
    s <= 1'sbx;
  end
endmodule
