// § foldedBoundTsRefUnstored144
module top(output logic [5:0] o);
   localparam int D = 5;
   logic [D:0] v;
   always_comb begin
     v = '0;
   end
   assign o = v;
endmodule
