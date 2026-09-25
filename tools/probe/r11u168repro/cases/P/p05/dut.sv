// § paramBaseSelTsInstName168
module top #(parameter [14:0] BASE_ADDR = 15'h0020, parameter DEC_WD = 4) (input [13:0] per_addr, output reg_sel);
wire rs = (BASE_ADDR[14:DEC_WD] == per_addr[13:DEC_WD-1]);
assign reg_sel = rs;
endmodule
