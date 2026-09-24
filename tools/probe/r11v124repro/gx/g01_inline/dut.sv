// § aggRngSkipInlineBody124v
package pkg; typedef struct packed { logic [1:0] x; } [3:0] b; endpackage
module top(output pkg::b o); assign o = '0; endmodule
