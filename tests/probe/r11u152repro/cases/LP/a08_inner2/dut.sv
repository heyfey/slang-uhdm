// § genLpOperandTsNoParent152
module top(output int o [2]);
   parameter int RhoOffset [2]  = '{0, 1};
   for (genvar i = 0 ; i < 1 ; i++) begin
      for (genvar y = 0 ; y < 2 ; y++) begin
         localparam int Offset = RhoOffset[1];
         assign o[y] = Offset;
      end
  end
endmodule
