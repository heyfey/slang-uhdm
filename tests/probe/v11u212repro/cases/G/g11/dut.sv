// § ndaSysCallNetTs212 — verifier: a net declaration assignment of $unsigned in a module that is instantiated twice with a width parameter
module c #(parameter int W = 4) (input logic signed [W-1:0] i, output logic [W-1:0] o);
  wire [W-1:0] w = $unsigned(i);
  assign o = w;
endmodule
module dut (input logic signed [7:0] i, output logic [3:0] o, output logic [7:0] o2);
  c #(4) u (.i(i[3:0]), .o(o));
  c #(8) v (.i(i), .o(o2));
endmodule
