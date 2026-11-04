// § dpDepBitNegUint489
interface ifc #(parameter A = 4); localparam B = ~A; logic [7:0] o; assign o = B; endinterface
module top; ifc u(); endmodule
