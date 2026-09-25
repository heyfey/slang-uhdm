// § defPkgStructParamMemberNames154
package p; typedef struct { int unsigned W; } s_t; localparam s_t D1 = '{W: 4}; localparam s_t D2 = '{W: 8}; endpackage
interface tif #(parameter p::s_t X = p::D1, parameter p::s_t Y = p::D2); logic [X.W-1:0] a; logic [Y.W-1:0] b; endinterface
module top(output logic [3:0] o); tif t(); assign o = t.a; endmodule
