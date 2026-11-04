// § sysCallKwTypeArgNameSpan131
module top (output logic [63:0] o);
  localparam int P = $bits(longint);
  localparam int Q = $bits(reg);
  assign o = P + Q;
endmodule
