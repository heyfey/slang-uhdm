// § elabParamRefSignedTsUnlocated264
module sub #(parameter int W = 4) (output logic [7:0] o);
  localparam int W2 = W;
  assign o = W2 + 1;
endmodule
module top(output logic [7:0] o);
  localparam int PP = 5;
  sub #(.W(PP)) u(.o(o));
endmodule
