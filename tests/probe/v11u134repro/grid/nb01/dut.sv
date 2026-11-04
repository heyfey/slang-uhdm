// § elabNetTdCloneNoAlias134
module leaf #(parameter int W = 4) (input logic [W-1:0] i, output logic [W-1:0] o);
  typedef logic [W-1:0] v_t;
  wire v_t w;
  assign w = i;
  assign o = w;
endmodule
module top(input logic [7:0] i, output logic [3:0] o1, output logic [7:0] o2);
  leaf #(4) a(.i(i[3:0]), .o(o1));
  leaf #(8) b(.i(i), .o(o2));
endmodule
