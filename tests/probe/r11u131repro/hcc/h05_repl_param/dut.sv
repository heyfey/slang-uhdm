// § hiConnConstTsName131
module sub(input logic [7:0] a); endmodule
module top; parameter W = 8; sub u(.a({W{1'b1}})); endmodule
