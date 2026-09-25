// § foldedBoundTsRefUnstored144
module top(input logic [5:0] a, output logic [5:0] o);
   localparam int D = 2;
   for (genvar i = 0; i < 2; i++) begin : g
      logic [D:0] t;
      assign t = a[i*3 +: 3];
      assign o[i*3 +: 3] = t;
   end
endmodule
