// § unitVarRefMintsNet418
logic [7:0] g = 8'd5;
module top (output logic o);
  assign o = g[3];
endmodule
