// § ifaceMemberTrailIdxNamesByPath147 § tpElemPatAtUser152
interface bus_if;
  logic [3:0] ben;
endinterface
module child #(parameter type id_t = logic [1:0], localparam type rt_t = id_t [1:0])
  (bus_if sub, input rt_t s, output logic o);
  assign o = sub.ben[s[0]];
endmodule
module top (input logic [3:0] ben_i, input logic [3:0] s, output logic o);
  bus_if sub ();
  assign sub.ben = ben_i;
  child c (.sub(sub), .s(s), .o(o));
endmodule
