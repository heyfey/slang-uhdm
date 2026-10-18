// § moduleNamedClocking402
module top(input clk, input a);
default clocking dc @(posedge clk); endclocking
clocking cn @(negedge clk); input a; endclocking
endmodule
