// § bareOvRefUint64_487
module m #(parameter A = 4) (output logic [7:0] o); localparam B = A; n #(.X(B)) v(o); endmodule
module n #(parameter X = 1) (output logic [7:0] o); assign o = X; endmodule
module top; logic [7:0] o; m #(.A(5)) u(o); endmodule
