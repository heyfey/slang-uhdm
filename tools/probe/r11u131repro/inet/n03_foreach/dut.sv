// § implicitNetMintNoFile131
module top(input logic [3:0] i, output logic [3:0] o);
  logic [3:0] a;
  always_comb begin
    foreach (a[j]) o[j] = i[j];
  end
endmodule
