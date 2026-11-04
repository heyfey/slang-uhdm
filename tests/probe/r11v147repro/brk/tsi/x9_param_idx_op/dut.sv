// § ifaceMemberTrailIdxNamesByPath147
interface bus_if;
  logic [7:0] ben;
endinterface
module child #(parameter int K = 2) (bus_if sub, input logic [1:0] s, output logic o);
  assign o = sub.ben[s + K];
endmodule
module top (input logic [7:0] ben_i, input logic [1:0] s, output logic o);
  bus_if sub ();
  assign sub.ben = ben_i;
  child #(3) c (.sub(sub), .s(s), .o(o));
endmodule
