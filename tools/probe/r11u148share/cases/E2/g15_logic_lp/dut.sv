module top(output logic [3:0] o);
   parameter int X = 2;
   for (genvar i = 0 ; i < 1 ; i++) begin : g
      localparam logic [3:0] L = X + 1;
      assign o = L;
   end
endmodule
