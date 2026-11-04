// § escIdPpColumnShift146
`define ID(x) x
module top(input logic i, output logic o);
  logic \w$ ; assign \w$ = i;
  assign o = `ID(i) & \w$ ;
endmodule
