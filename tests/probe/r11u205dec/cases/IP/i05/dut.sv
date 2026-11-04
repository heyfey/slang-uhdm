// r11u205 IP i05: control, the indexed part select on the RIGHT side of a generate assignment
interface bif;
  logic [7:0] d;
endinterface
module dut(input logic [7:0] x, output logic [3:0] o);
  bif b();
  assign b.d = x;
  for (genvar k = 0; k < 1; k++) begin : g
    assign o = b.d[0+:4];
  end
endmodule
