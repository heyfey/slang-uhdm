// § bitNegTypedOperandSize491
module m #(parameter bit [7:0] A = 4'd4) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o[2];
for (genvar g = 0; g < 2; g++) begin : gb m u(o[g]); end
endmodule
