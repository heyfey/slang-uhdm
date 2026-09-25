// § ifacePortViewFoldAtLeftOperand155
interface bus_if #(parameter int DAT = 32);
  localparam int unsigned BYT = DAT/8;
  logic [BYT-1:0] ben;
endinterface
module child (bus_if sub, output logic [3:0] o);
  for (genvar i = 0; i < sub.BYT; i++) begin : g
    assign o[i] = sub.ben[i];
  end
endmodule
module top (input logic [3:0] ben_i, output logic [3:0] o1, o2);
  bus_if #(.DAT(32)) s1 ();
  bus_if #(.DAT(32)) s2 ();
  assign s1.ben = ben_i;
  assign s2.ben = ~ben_i;
  child c1 (.sub(s1), .o(o1));
  child c2 (.sub(s2), .o(o2));
endmodule
