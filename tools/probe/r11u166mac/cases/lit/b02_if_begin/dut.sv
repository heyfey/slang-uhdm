// § ppBasedLitWsAfter166
module top(input [2:0] s, output logic r);
  always_comb begin
    r = 1'b0;
    if (s == 3'b 101) begin
      r = 1'b1;
    end
  end
endmodule
