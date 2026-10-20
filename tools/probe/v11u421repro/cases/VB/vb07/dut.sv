// § bitsDefNoFoldNoTs421
module top #(parameter w_p = 4) (output logic [7:0] o);
  typedef struct packed { logic [w_p-1:0] d; logic b; } pk_s;
  for (genvar i = 0; i < 2; i++) begin : g
    localparam W = $bits(pk_s) + i;
    localparam V = $bits(pk_s);
    assign o[i] = V[0];
  end
endmodule
