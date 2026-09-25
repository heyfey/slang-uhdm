// § ifaceMemberTrailIdxNamesByPath147
interface bus_if;
  logic [7:0] ben;
endinterface
module child (bus_if sub, input logic [3:0] s, output logic o);
  assign o = sub.ben[s[2:0]];
endmodule
module top (input logic [7:0] ben_i, input logic [3:0] s, output logic o);
  bus_if sub ();
  assign sub.ben = ben_i;
  child c (.sub(sub), .s(s), .o(o));
endmodule
