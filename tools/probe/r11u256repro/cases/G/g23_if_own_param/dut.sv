// § genIpsBoundOwner256 (if-generate, the module's own header parameter as the width, whole right side, overridden at the instance: Earlgrey prim_ram_1p_adv gen_nosecded_noparity; residue)
module m #(parameter int Width = 32, parameter bit E = 0) (input logic [7:0] a, output logic [2:0] q);
  if (E) begin : gs
    assign q = '0;
  end else begin : gn
    assign q = a[0+:Width];
  end
endmodule
module top(input logic [7:0] a, output logic [2:0] q);
  m #(.Width(3)) u (.*);
endmodule
