// § ifaceMemberTrailIdxNamesByPath147 § tpElemPatAtUser152
interface bus_if #(parameter type id_t = logic [1:0], localparam type rt_t = id_t [3:0]);
  rt_t ben;
endinterface
module child (bus_if sub, input logic [1:0] s, output logic [1:0] o);
  assign o = sub.ben[s];
endmodule
module top (input logic [7:0] ben_i, input logic [1:0] s, output logic [1:0] o);
  bus_if sub ();
  assign sub.ben = ben_i;
  child c (.sub(sub), .s(s), .o(o));
endmodule
