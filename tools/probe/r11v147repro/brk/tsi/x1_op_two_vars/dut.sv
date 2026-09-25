// § ifaceMemberTrailIdxNamesByPath147
interface bus_if;
  logic [7:0] ben;
endinterface
module child (bus_if sub, input logic [1:0] s, input logic [1:0] t, output logic o);
  assign o = sub.ben[s + t];
endmodule
module top (input logic [7:0] ben_i, input logic [1:0] s, input logic [1:0] t, output logic o);
  bus_if sub ();
  assign sub.ben = ben_i;
  child c (.sub(sub), .s(s), .t(t), .o(o));
endmodule
