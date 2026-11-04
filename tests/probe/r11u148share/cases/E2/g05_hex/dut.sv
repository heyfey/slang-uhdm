module top(output logic [7:0] o);
   for (genvar i = 0 ; i < 1 ; i++) begin : g
      localparam logic [7:0] L = 8'hA5;
      assign o = L;
   end
endmodule
