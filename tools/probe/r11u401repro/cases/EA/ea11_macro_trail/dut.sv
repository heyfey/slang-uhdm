// § sysCallEmptyArgIsIntZero401
`define D(x,y) initial $display("start", x , y, "end");
module top ();
`D( " msg1", )
endmodule
