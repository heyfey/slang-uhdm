// § ifacePortViewFoldAtLeftOperand155
interface bus_if #(parameter int DAT = 32);
  localparam int unsigned BYT = DAT/8;
  logic [BYT-1:0] ben;
endinterface
module child (bus_if sub, output logic [3:0] o);
  generate
    for (genvar i = 0; i < sub.BYT; i++) begin : g
      assign o[i] = sub.ben[i];
    end
  endgenerate
endmodule
module top (input logic [3:0] ben_i, input logic [1:0] b2, output logic [3:0] o, output logic [3:0] o2);
  bus_if #(.DAT(32)) sub ();
  bus_if #(.DAT(16)) sub2 ();
  assign sub.ben = ben_i;
  assign sub2.ben = b2;
  child c (.sub(sub), .o(o));
  child c2 (.sub(sub2), .o(o2));
endmodule
