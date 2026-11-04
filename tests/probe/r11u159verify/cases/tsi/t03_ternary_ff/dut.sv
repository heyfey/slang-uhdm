// § ifaceMemberTrailIdxNamesByPath147
interface bus_if #(parameter int W = 4);
  logic [W-1:0] ben;
endinterface
module child (bus_if sub, input logic clk, input logic [1:0] s, output logic o);
  always_ff @(posedge clk) o <= s[0] ? sub.ben[s] : 1'b0;
endmodule
module top (input logic clk, input logic [3:0] ben_i, input logic [1:0] s, output logic o);
  bus_if #(.W(4)) sub ();
  assign sub.ben = ben_i;
  child c (.sub(sub), .clk(clk), .s(s), .o(o));
endmodule
