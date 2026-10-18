// § implicitNetDefLastRef404
primitive inv1 (o, i);
output o; input i;
table
0 : 1;
1 : 0;
endtable
endprimitive
module top (input a, input b);
inv1 g1 (n1, a);
inv1 (n2, b);
inv1 (n3, n1);
initial $display("%b %b %b", n1, n2, n3);
endmodule
