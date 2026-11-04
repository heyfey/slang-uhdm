// § bitNegBareNameActual491
module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; logic [7:0] o;
if (1) begin : g localparam P = 5; m #(.A(P)) u(o); end
endmodule
