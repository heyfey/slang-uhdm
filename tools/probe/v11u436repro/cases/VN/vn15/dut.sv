// § nestedModGateUpwardNet436
module top(input a, b, output y, output z);
module sub;
and g1 (y, a, b);
endmodule
sub i1();
for (genvar k = 0; k < 1; k++) begin : gl
sub i2();
end
assign z = y;
endmodule
