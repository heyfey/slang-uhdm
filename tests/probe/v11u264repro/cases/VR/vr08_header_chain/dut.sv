// § elabParamRefSignedTsUnlocated264
module sub #(parameter int A = 5, parameter int B = A, parameter int C = B) (output logic [31:0] o);
  localparam int D = C;
  assign o = A + B + C + D;
endmodule
module top(output logic [31:0] o, output logic [31:0] p);
  sub u(.o(o));
  sub #(.A(7)) v(.o(p));
endmodule
