// § nestedModGateUpwardNet436
module top(input a, b, output y);
module sub;
nand g1 (y, a, b);
endmodule
for (genvar k = 0; k < 2; k++) begin : gl
sub i1();
end
endmodule
