// § ifaceMemberTrailIdxNamesByPath147
interface in_if;
  logic [3:0] ben;
endinterface
interface bus_if;
  in_if inner ();
endinterface
module top (input logic [3:0] ben_i, input logic [1:0] s, output logic o);
  bus_if sub ();
  assign sub.inner.ben = ben_i;
  assign o = sub.inner.ben[s];
endmodule
