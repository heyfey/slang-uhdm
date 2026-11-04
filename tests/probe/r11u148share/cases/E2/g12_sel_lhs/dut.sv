module top(output logic [7:0] o);
   for (genvar i = 0 ; i < 1 ; i++) begin : g
      localparam int L = 2 + 3;
      assign o[3:0] = L;
   end
   assign o[7:4] = '0;
endmodule
