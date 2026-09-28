// § hiddenBlockVarMintNoFile207: hidden block logic inside a task, read before written, and the same name hidden in two blocks of one module
module mod (in, out);
input in;
output out;
reg out;
task tk;
input a;
begin : tb
logic h;
h = a;
out = h;
end
endtask
always @(posedge in) begin : b1
logic hold;
hold = in;
end
always @(negedge in) begin : b2
logic hold;
hold = ~in;
end
endmodule
module top (i, o);
input i;
output o;
mod u(i, o);
endmodule
