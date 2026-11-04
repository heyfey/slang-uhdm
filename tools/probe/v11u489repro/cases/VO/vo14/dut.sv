// § ovSizedActualSize489
module m #(parameter A = 4'd15) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] w [2]; for (genvar i = 0; i < 2; i++) begin : g m #(.A(4'd3)) u(w[i]); end endmodule
