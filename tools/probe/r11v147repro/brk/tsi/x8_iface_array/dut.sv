// § ifaceMemberTrailIdxNamesByPath147
interface bus_if;
  logic [3:0] ben;
endinterface
module top (input logic [3:0] ben_i, input logic [1:0] s, output logic [1:0] o);
  bus_if sub [2] ();
  assign sub[0].ben = ben_i;
  assign sub[1].ben = ~ben_i;
  assign o[0] = sub[0].ben[s];
  assign o[1] = sub[1].ben[s + 1];
endmodule
