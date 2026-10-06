// § elabParamRefSignedTsUnlocated264
module sub #(parameter bit EP = 1, parameter int W = 32, parameter int DB = 2) (output logic [31:0] o);
  localparam int L1 = (EP) ? W/8 : DB;
  localparam int L2 = EP ? DB : 1;
  localparam int L3 = !EP ? 1 : (W > 8 ? DB : W);
  localparam int L4 = (W == 32) ? W : 0;
  localparam int L5 = EP ? 4'd3 : DB;
  assign o = L1 + L2 + L3 + L4 + L5;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
