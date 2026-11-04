// § ifaceMemberTrailIdxNamesByPath147
interface bus_if;
  logic [3:0] ben;
endinterface
module child (bus_if sub, output logic o);
  assign o = sub.ben[2];
endmodule
module top (input logic [3:0] ben_i, output logic o);
  bus_if sub ();
  assign sub.ben = ben_i;
  child c (.sub(sub), .o(o));
endmodule
