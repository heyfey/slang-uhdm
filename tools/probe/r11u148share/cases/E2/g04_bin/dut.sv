module top(output logic [3:0] o);
   for (genvar i = 0 ; i < 1 ; i++) begin : g
      localparam logic [3:0] L = 4'b1010;
      assign o = L;
   end
endmodule
