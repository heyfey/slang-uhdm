// § hiConnConstTsName131
module sub(input logic [7:0] a); endmodule
module top; parameter P = 3; sub u(.a(P)); endmodule
