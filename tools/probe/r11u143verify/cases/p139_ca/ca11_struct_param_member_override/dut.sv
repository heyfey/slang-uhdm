// § caLhsDefNetUnlessOpRhs139
// case ca11: a member of a struct value parameter as the right-hand side, the instance overrides it
package ps; typedef struct packed { logic [1:0] f; logic g; } s_t; endpackage
module sub #(parameter ps::s_t P = '{f: 2'd1, g: 1'b0}) (output logic [1:0] y);
  assign y = P.f;
endmodule
module top(output logic [1:0] y); sub #(.P('{f: 2'd2, g: 1'b1})) u(.y(y)); endmodule
