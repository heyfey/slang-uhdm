// § ifaceMemberTrailIdxNamesByPath147
interface bus_if;
  logic [4:0] ben;
endinterface
module child (bus_if sub, output logic [3:0] o);
  for (genvar i = 0; i < 4; i++) begin : g
    assign o[i] = sub.ben[i+1];
  end
endmodule
module top (input logic [4:0] ben_i, output logic [3:0] o);
  bus_if sub ();
  assign sub.ben = ben_i;
  child c (.sub(sub), .o(o));
endmodule
