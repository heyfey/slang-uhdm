module top(output logic [1:0] o);
   for (genvar i = 0 ; i < 1 ; i++) begin : g
      localparam int L = 3 + 4;
      assign o = L;
   end
endmodule
