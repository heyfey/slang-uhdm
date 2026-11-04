// § ovUnsizedBasedActualForm491
interface ifc #(parameter A = 4); logic [7:0] o; assign o = A; endinterface
module top; ifc #(.A('h5)) u(); endmodule
