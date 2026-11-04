// § sysCallEmptyArgIsIntZero401
`define MACRO1(a=5,b="B",c) initial $display(a,,b,,c);
module top ();
`MACRO1 ( 1 , , 3 )
endmodule
