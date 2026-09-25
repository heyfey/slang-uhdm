// § genLpUintCaRhsOwnCopy148
module top(output int o);
   parameter int X = 1;
   if (X > 0) begin : g
      localparam int Offset = X + 2;
      assign o = Offset;
   end
endmodule
