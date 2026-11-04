// § dpConstUintForm489
interface ifc #(parameter A = 4'd4); logic [7:0] o; assign o = A; endinterface
module top; ifc u(); defparam u.A = 6; endmodule
