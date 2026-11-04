// r11u205 IP i02: the same target in an if-generate
interface bif;
  logic [7:0] d;
endinterface
module dut #(parameter int P = 1) (input logic [3:0] x, output logic [7:0] o);
  bif b();
  if (P == 1) begin : g
    assign b.d[4+:4] = x;
  end
  assign o = b.d;
endmodule
