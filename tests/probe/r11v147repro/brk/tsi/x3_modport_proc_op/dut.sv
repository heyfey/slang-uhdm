// § ifaceMemberTrailIdxNamesByPath147
interface bus_if;
  logic [7:0] ben;
  modport mp (input ben);
endinterface
module child (bus_if.mp sub, input logic [2:0] s, output logic o);
  always_comb begin
    o = sub.ben[s - 1];
  end
endmodule
module top (input logic [7:0] ben_i, input logic [2:0] s, output logic o);
  bus_if sub ();
  assign sub.ben = ben_i;
  child c (.sub(sub), .s(s), .o(o));
endmodule
