// § unitVarRefMintsNet418
logic [3:0] g;
module top (input logic [3:0] a, output logic [3:0] o);
  always_comb o = a ^ g;
endmodule
