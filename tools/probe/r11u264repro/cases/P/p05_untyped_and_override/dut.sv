// § elabParamRefSignedTsUnlocated264
module sub #(parameter int D = 16, parameter bit EP = 0) (output logic [7:0] o);
  localparam int AW = $clog2(D);
  localparam B = AW;
  localparam int C = (EP) ? 1 : AW;
  localparam int E = D;
  assign o = B + C + E;
endmodule
module top(output logic [7:0] o);
  sub #(.D(64), .EP(1)) u(.o(o));
endmodule
