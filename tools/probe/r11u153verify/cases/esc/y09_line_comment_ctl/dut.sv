// § escIdPpColumnShift146
module top(input logic i, output logic o);
  assign o = i & i; // \x$ trailing comment
endmodule
