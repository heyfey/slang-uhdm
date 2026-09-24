// § hiConnConstTsName131
module sub(input logic [7:0] a); endmodule
module top; sub u(.a({4'h1, 4'h2})); endmodule
