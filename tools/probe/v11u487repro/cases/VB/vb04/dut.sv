// § bareOvRefUint64_487
interface ifc #(parameter A = 4); localparam B = A; logic [7:0] o; assign o = B; endinterface
module top; ifc #(.A(5)) u(); endmodule
