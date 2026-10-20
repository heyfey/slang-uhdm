// § unitVarRefMintsNet418
logic [7:0] un;
module top (output logic [31:0] o);
  if (1) begin : g
    logic [31:0] un;
    assign un = 32'd5;
    assign o = un;
  end
endmodule
