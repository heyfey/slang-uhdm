// § unboundedTypedParamTs405
module top();
parameter i = $;
initial $display("%d", $isunbounded(i));
endmodule
