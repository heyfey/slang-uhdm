// § sysCallKwTypeArgNameSpan131
module top (output logic [31:0] o);
  localparam int P = $bits(logic [3:0]);
  assign o = P;
endmodule
