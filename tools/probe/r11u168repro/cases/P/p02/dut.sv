// § paramBaseSelTsInstName168
module sub #(parameter [7:0] P = 8'h5a, parameter I = 3) (output o, output o2);
wire w = P[I];
wire w2 = P[I+1];
assign o = w; assign o2 = w2;
endmodule
module top(output o, output o2); sub s(.o(o), .o2(o2)); endmodule
