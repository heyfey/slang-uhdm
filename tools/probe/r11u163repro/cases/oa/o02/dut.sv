// § elabOvArrFoldSharesDefParamTs163
module decoder #(
    parameter int              IFN = 2,
    parameter logic [7:0]      DAM [IFN-1:0] = '{ 8'h0, 8'h0 }
)(
    input  logic [7:0] adr,
    output logic [IFN-1:0] mch
);
    for (genvar i=0; i<IFN; i++)
        assign mch[i] = adr ==? DAM[i];
endmodule
module dut (input logic [7:0] adr, output logic [1:0] m1, output logic [2:0] m2);
    decoder #(.IFN(2), .DAM({8'bxxxx_xx1x, 8'bxxxx_xx0x})) u1 (.adr(adr), .mch(m1));
    decoder #(.IFN(3), .DAM({8'b1xxx_xxxx, 8'b01xx_xxxx, 8'b00xx_xxxx})) u2 (.adr(adr), .mch(m2));
endmodule
