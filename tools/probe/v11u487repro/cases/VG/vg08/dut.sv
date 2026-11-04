// § caFoldLhsWidthGrow487
interface ifc #(parameter logic [3:0] A = 4); logic [7:0] o; assign o = A; endinterface
module top; ifc #(.A(5)) u(); endmodule
