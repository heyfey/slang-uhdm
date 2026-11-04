// § ifaceMemberTrailIdxNamesByPath147
interface bus_if;
  logic [3:0] ben;
endinterface
module child (bus_if sub, input logic clk, input logic [1:0] s, input logic d);
  always_ff @(posedge clk) sub.ben[s] <= d;
endmodule
module top (input logic clk, input logic [1:0] s, input logic d, output logic [3:0] o);
  bus_if sub ();
  assign o = sub.ben;
  child c (.sub(sub), .clk(clk), .s(s), .d(d));
endmodule
