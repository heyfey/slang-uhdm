// § paramBaseSelTsInstName168
module sub #(parameter [14:0] BASE_ADDR = 15'h0020, parameter DEC_WD = 4) (input [13:0] per_addr, input per_en, output o);
wire reg_sel = per_en & (per_addr[13:DEC_WD-1] == BASE_ADDR[14:DEC_WD]);
assign o = reg_sel;
endmodule
module top(input [13:0] a, input e, output o); sub #(.BASE_ADDR(15'h0100)) s(.per_addr(a), .per_en(e), .o(o)); endmodule
