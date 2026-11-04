// § ovUnsizedBasedActualForm491
interface ifc #(parameter X = 1); logic [7:0] o; assign o = X; endinterface
module m #(parameter A = 4) (output logic [7:0] o); ifc #(.X(A)) c(); assign o = c.o; endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
