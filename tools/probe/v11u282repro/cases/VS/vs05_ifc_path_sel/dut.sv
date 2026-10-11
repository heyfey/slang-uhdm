// § procSelNameFinal282v
package pk; parameter int P = 4; endpackage
interface ifc; logic [7:0] f; endinterface
module top import pk::*; (ifc i, output logic z [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb z[w] = i.f[P-1];
  end
endmodule
module wrap(input logic [7:0] a, output logic z [2]); ifc ii(); assign ii.f = a; top u(.i(ii), .z(z)); endmodule
