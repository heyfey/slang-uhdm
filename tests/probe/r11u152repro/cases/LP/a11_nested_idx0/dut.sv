// § genLpOperandTsNoParent152
module top(output int o);
   parameter int RhoOffset [3]  = '{5, 6, 7};
   for (genvar i = 0 ; i < 1 ; i++) begin
      for (genvar y = 0 ; y < 1 ; y++) begin
         localparam int Offset = RhoOffset[0];
         assign o = Offset;
      end
  end
endmodule
