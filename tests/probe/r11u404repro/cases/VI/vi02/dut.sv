// § varInitOpCastKept404
`define VAR_1 3
`define VAR_2 4
module top();
int a = `VAR_1 + `VAR_2;
endmodule
