// § ovSizedActualSize489
interface ifc #(parameter A = 4'd15); logic [7:0] o; assign o = A; endinterface
module top; ifc #(.A(4'd3)) u(); endmodule
