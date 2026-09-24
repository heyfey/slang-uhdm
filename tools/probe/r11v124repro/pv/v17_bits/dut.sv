// § paramValueIsDefRhs124
module top(output int o); parameter int P = $bits(logic [11:0]); localparam type T = logic [5:0]; localparam int Q = $bits(T); assign o = P + Q; endmodule
