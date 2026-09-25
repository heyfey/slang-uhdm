// § portInitAssignAtHeader146
module sub(o); output reg o = 1; endmodule
module top(output y); sub u(y); endmodule
