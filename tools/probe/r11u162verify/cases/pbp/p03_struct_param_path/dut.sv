// § psBoundPathFirstMember154
package p; typedef struct packed { logic [3:0] W; logic [3:0] O; } c_t; endpackage
module m #(parameter p::c_t C = '{W: 5, O: 1}) (input logic [7:0] v, output logic [4:0] o);
  assign o = v[C.W:C.O];
endmodule
module top(input logic [7:0] v, output logic [4:0] o); m u(v, o); endmodule
