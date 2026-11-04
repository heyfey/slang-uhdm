// § unsignedScalarParamTsAtKeyword145
module top;
    if (1) begin : a
        localparam logic unsigned y = -1;
        logic [127:0] b = y;
    end
    if (1) begin : c
        localparam logic signed y = -1;
        logic [127:0] b = y;
    end
endmodule
