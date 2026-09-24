// § hiConnConstTsName131
module sub(input logic [7:0] a); endmodule
module top; for (genvar i = 0; i < 2; i++) begin : g sub u(.a({8{1'b1}})); end endmodule
