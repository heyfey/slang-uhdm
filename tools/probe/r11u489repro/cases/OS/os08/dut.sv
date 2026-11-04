// § ovSizedActualSize489
module m #(parameter A = 4'd15) (output logic [7:0] o); localparam B = 1; endmodule
module top; logic [7:0] o; m #(.A(5)) u(o); endmodule
