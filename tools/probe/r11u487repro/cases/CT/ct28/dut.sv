// § caFoldTsFollowsPa487
interface ifc #(parameter A = 4); localparam B = A + 1; logic [7:0] o; assign o = B; endinterface
module top; ifc u(); endmodule
