// § refChainHexWrittenCase475
// a child override of the hex origin
module sub #(parameter logic [7:0] HA = 8'hcd, parameter logic [7:0] HB = HA) (output logic [7:0] y);
  assign y = HB;
endmodule
module top(output logic [7:0] y1, y2);
  sub #(.HA(8'hef)) u1(y1);
  sub u2(y2);
endmodule
