// § moduleNamedClocking402
module top(input clk);
clocking ck1 @(posedge clk);
	default input #10ns output #5ns;
endclocking
endmodule
