// § unboundedTypedParamTs405
module top();
parameter int i = $;
initial $display("%d", $isunbounded(i));
endmodule
