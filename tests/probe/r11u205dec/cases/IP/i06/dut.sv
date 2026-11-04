// r11u205 IP i06: nested generates, the target an interface member's indexed part select
interface bif;
  logic [7:0] d;
endinterface
module dut #(parameter int P = 1) (input logic [3:0] x, output logic [7:0] o);
  bif b();
  if (P == 1) begin : ga
    for (genvar k = 0; k < 1; k++) begin : gb
      assign b.d[0+:4] = x;
    end
  end
  assign o = b.d;
endmodule
