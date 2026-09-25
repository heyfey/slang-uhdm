// § ifaceMemberTrailIdxNamesByPath147
interface bus_if;
  logic [3:0] ben;
  modport m (input ben);
endinterface
module child (bus_if.m sub, input logic [1:0] s, output logic o);
  assign o = sub.ben[s];
endmodule
module top (input logic [3:0] ben_i, input logic [1:0] s, output logic o);
  bus_if sub ();
  assign sub.ben = ben_i;
  child c (.sub(sub), .s(s), .o(o));
endmodule
