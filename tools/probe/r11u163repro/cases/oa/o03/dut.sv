// § elabOvArrFoldSharesDefParamTs163
module decoder #(
    parameter logic [3:0]      DAM [1:0] = '{ 4'h0, 4'h0 }
)(
    input  logic [3:0] adr,
    output logic [1:0] mch
);
    assign mch[0] = adr ==? DAM[0];
    assign mch[1] = adr ==? DAM[1];
endmodule
module dut (input logic [3:0] adr, output logic [1:0] m);
    decoder #(.DAM({4'b1x0x, 4'b0x1x})) u (.adr(adr), .mch(m));
endmodule
