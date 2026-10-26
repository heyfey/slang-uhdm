// § newLhsHpSelFirstSpan437
module top(input clk, input [3:0] a);
covergroup cg @(posedge clk); coverpoint a; endgroup
class H; cg c[2]; endclass
H h;
initial begin h = new; h.c[0] = new; end
endmodule
