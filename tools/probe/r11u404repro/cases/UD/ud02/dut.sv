// § undefaultedDefInvalidInst404
module child #(parameter w_p, parameter type t_p) (input [w_p-1:0] a);
endmodule
module child__abstract(); if (0) begin : abstract child not_used(); end endmodule
module top; endmodule
