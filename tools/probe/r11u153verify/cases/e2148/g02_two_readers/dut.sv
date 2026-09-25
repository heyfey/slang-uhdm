// § genLpUintCaRhsOwnCopy148
module top(output int o, output int p);
   parameter int X = 1;
   for (genvar i = 0 ; i < 1 ; i++) begin : g
      localparam int Offset = X + 3;
      assign o = Offset;
      assign p = Offset;
   end
endmodule
