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
module dut (input logic [7:0] adr, output logic [3:0] m);
    for (genvar g = 0; g < 2; g++) begin : gb
      decoder #(.IFN(2), .DAM({8'bxxxx_xx1x, 8'bxxxx_xx0x})) u (.adr(adr), .mch(m[2*g +: 2]));
    end
endmodule
