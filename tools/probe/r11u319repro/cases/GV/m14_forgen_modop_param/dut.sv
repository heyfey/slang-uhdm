// § defGenIdxModPowOp319
module mod(input logic a);
endmodule
module top #(parameter int P = 5) (input logic [7:0] v, input logic [1:0] s, output logic o);
  for (genvar c = 0; c < 2; c++) begin : g
    mod n(.a(v[c % 2]));
  end
  assign o = v[0];
endmodule
