// § ifaceMemberTrailIdxNamesByPath147
interface bus_if;
  logic [3:0] ben;
  logic [1:0] sel;
endinterface
module child (bus_if sub, output logic o);
  assign o = sub.ben[sub.sel];
endmodule
module top (input logic [3:0] ben_i, input logic [1:0] s, output logic o);
  bus_if sub ();
  assign sub.ben = ben_i;
  assign sub.sel = s;
  child c (.sub(sub), .o(o));
endmodule
