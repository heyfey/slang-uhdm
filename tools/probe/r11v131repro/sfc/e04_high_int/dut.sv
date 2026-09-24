// § sysCallKwTypeArgNameSpan131
module top (output logic [31:0] o);
  localparam int P = $high(int);
  localparam int Q = $left(byte);
  assign o = P + Q;
endmodule
