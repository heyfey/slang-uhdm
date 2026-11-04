// § ifacePortViewFoldAtLeftOperand155
interface bus_if #(parameter int DAT = 32);
  localparam int unsigned BYT = DAT/8;
  logic [BYT-1:0] ben;
endinterface
module leaf (bus_if sub, output logic [3:0] o);
  for (genvar i = 0; i < sub.BYT; i++) begin : g
    assign o[i] = sub.ben[i];
  end
endmodule
module mid (bus_if sub, output logic [3:0] o); leaf l (.sub(sub), .o(o)); endmodule
module top (input logic [3:0] ben_i, output logic [3:0] o);
  bus_if #(.DAT(32)) sub ();
  assign sub.ben = ben_i;
  mid m (.sub(sub), .o(o));
endmodule
