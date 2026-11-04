// § bitNegBareNameActual491
module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; localparam P = 5; logic [7:0] o[2];
for (genvar g = 0; g < 2; g++) begin : gb m #(.A(P)) u(o[g]); end
endmodule
