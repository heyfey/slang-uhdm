// § ifaceMemberTrailIdxNamesByPath147
interface bus_if;
  logic [3:0] ben;
endinterface
module top (input logic [3:0] ben_i, input logic [1:0] s, output logic [1:0] o);
  bus_if sub ();
  assign sub.ben = ben_i;
  for (genvar g = 0; g < 2; g++) begin : gg
    assign o[g] = sub.ben[s];
  end
endmodule
