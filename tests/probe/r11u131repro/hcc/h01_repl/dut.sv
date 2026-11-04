// § hiConnConstTsName131
module sub(input logic [7:0] a); endmodule
module top; sub u(.a({8{1'b1}})); endmodule
