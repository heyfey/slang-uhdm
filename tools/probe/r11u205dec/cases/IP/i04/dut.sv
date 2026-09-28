// r11u205 IP i04: a descending indexed part select of an interface member as a generate target
interface bif;
  logic [7:0] d;
endinterface
module dut(input logic [3:0] x, output logic [7:0] o);
  bif b();
  for (genvar k = 0; k < 1; k++) begin : g
    assign b.d[7-:4] = x;
  end
  assign o = b.d;
endmodule
