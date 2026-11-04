// § genLpOperandTsNoParent152
module top(output int o);
   parameter int RhoOffset [2]  = '{0, 1};
   parameter int S = 1;
   case (S)
     1: begin : c
       for (genvar y = 0 ; y < 1 ; y++) begin
          localparam int Offset = RhoOffset[1];
          assign o = Offset;
       end
     end
   endcase
endmodule
