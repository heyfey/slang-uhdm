// § elabParamRefSignedTsUnlocated264
module top #(parameter int D = 16, parameter bit EP = 0) (output logic [7:0] o);
  localparam int AW = $clog2(D);
  localparam int B = AW;
  localparam int C = (EP) ? 1 : AW;
  localparam int E = B;
  assign o = B + C + E;
endmodule
