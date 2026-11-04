// § hiConnConstTsName131
module sub(input logic [7:0] a); endmodule
module mid; sub u(.a({8{1'b0}})); endmodule
module top; mid m(); endmodule
