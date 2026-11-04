// § paramBaseSelTsInstName168
module sub #(parameter [14:0] BASE_ADDR = 15'h0020, parameter DEC_WD = 4) (output o);
localparam [14:0] LB = BASE_ADDR;
wire w = LB[DEC_WD] & BASE_ADDR[DEC_WD-1];
assign o = w;
endmodule
module top(output o); sub s(.o(o)); endmodule
