// § paramValueIsDefRhs124
interface bus #(parameter W=4); logic [W-1:0] d; endinterface
module top(output logic [7:0] o); bus #(.W(8)) b(); assign b.d = 8'h5; assign o = b.d; endmodule
