// § macroIncludeCol410
`define STR(x) `"x`"
`define INC(f) `include `STR(f)
module top;
    `INC(inc.svh)
endmodule
