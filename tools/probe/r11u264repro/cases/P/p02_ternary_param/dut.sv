// § elabParamRefSignedTsUnlocated264
module sub #(parameter bit EP = 0, parameter int DB = 1, parameter int W = 32) (output logic [7:0] o);
  localparam int LD = (EP) ? 1 : DB;
  localparam int PW = (EP) ? W/8 : 0;
  assign o = LD + PW;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
