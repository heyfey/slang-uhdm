// § elabTpDefaultDefNamed163 § tpUseBindsDefDefault160
module ram #(parameter int DataWidth = 8, parameter type data_t = logic [DataWidth-1:0]) (input logic clk, output logic [7:0] o);
  data_t q;
  always_ff @(posedge clk) q <= '0;
  assign o = q;
endmodule
module top (input logic clk, output logic [7:0] o, output logic [7:0] o2);
  ram u1(.clk(clk), .o(o));
  ram u2(.clk(clk), .o(o2));
endmodule
