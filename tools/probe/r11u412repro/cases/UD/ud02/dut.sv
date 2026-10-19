// § udpInitTickValEmpty412
primitive p2 (q, clk, d);
input clk, d;
output q; reg q;
initial q = 0;
table
r 0 : ? : 0;
? * : ? : -;
endtable
endprimitive
primitive p3 (q, clk, d);
input clk, d;
output q; reg q;
initial q = 1'bx;
table
r 1 : ? : 1;
* ? : ? : -;
endtable
endprimitive
module top (input clk, d, output q, r);
p2 u1 (q, clk, d);
p3 u2 (r, clk, d);
endmodule
