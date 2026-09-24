// § foldedBoundTsRefUnstored144
interface ifc #(parameter int W = 4);
   logic [W-1:0] d;
endinterface
module top(output int o);
   localparam int D = 3;
   ifc #(.W(6)) u();
   if (1) begin : gi
     logic [D:0] w;
     assign w = '1;
   end
   assign u.d = '0;
   assign o = int'(u.d) + int'(gi.w);
endmodule
