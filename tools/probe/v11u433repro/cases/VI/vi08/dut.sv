// § connIdxUnitParamFold433
localparam S = 2;
module c(input a); endmodule
module top; struct packed {logic [7:0] f;} s; c u(.a(s.f[S])); endmodule
