// § unsignedScalarParamTsAtKeyword145
`define TEST(typ) \
    if (1) begin \
        typ x = -1; \
        localparam typ y = -1; \
        logic [127:0] b = y; \
    end
module top;
    `TEST(logic)
    `TEST(logic signed)
    `TEST(logic unsigned)
endmodule
