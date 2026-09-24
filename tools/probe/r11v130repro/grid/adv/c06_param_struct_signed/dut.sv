// § suSigningNotInSpan130
module top(output logic [7:0] o);
  localparam struct packed signed { logic [3:0] a; logic [3:0] b; } P = '{a: 4'd1, b: 4'd2};
  assign o = P;
endmodule
