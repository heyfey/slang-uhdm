// § untypedDepUnboundedValue489
program p #(parameter A = 4'd15) (output logic [7:0] o); localparam B = A + 4'd1; initial o = B; endprogram
module top; logic [7:0] o; p u(o); endmodule
