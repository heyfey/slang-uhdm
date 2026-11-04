module top(output logic [7:0] o);
   logic [7:0] w;
   assign w[0] = 1;
   assign w[7:1] = 7'h11;
   assign o = w;
endmodule
