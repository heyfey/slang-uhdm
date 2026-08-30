// r10earl102 g4_neg102 -- THE MUST-NOT-MOVE HALF.  Every shape here is one the
// law must leave exactly where it is: the param_array_wildcard shape (a
// MODULE parameter whose unpacked dim reads an OVERRIDDEN parameter, golden
// keeps the ref in every view), a module dim reading a BARE parameter
// reference (§ modUnpackedDimBareRef), the SIZE spelling `[N]`, and plain
// array VARIABLES and NETS whose dims read a parameter (a different producer
// path entirely).
module m4n102 #(
    parameter int              IFN = 2,
    parameter logic [31:0]     DAM [IFN-1:0] = '{ 32'h0, 32'h0 }
)(
    input  logic [31:0] adr,
    output logic [IFN-1:0] mch
);
    localparam int BN = 4;
    localparam int BARR [BN:0] = '{4, 3, 2, 1, 0};   // BARE ref bound
    localparam int SARR [BN]   = '{3, 2, 1, 0};      // SIZE spelling
    logic [7:0] avar [0:BN-1];                       // array VARIABLE
    wire  [7:0] anet [0:BN-1];                       // array NET
    for (genvar i=0; i<IFN; i++)
        assign mch[i] = adr ==? DAM[i];
    always_comb avar[0] = 8'(BARR[0] + SARR[0]);
    assign anet[0] = avar[0];
endmodule

module g4_neg102 (input logic [31:0] adr, output logic [1:0] mch);
    m4n102 #(
        .IFN (2),
        .DAM ({{17'bx, 15'bxx_xxxx_x1xx_xxxx},
               {17'bx, 15'bxx_xxxx_x0xx_xxxx}})
    ) u (.adr(adr), .mch(mch));
endmodule
