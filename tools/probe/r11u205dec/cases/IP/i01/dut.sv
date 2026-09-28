// r11u205 IP i01: a def-view for-generate continuous-assignment TARGET that is an indexed part select of an interface member (Rggen's N1249)
interface bif;
  logic [7:0] d;
endinterface
module dut(input logic [3:0] x, output logic [7:0] o);
  bif b();
  for (genvar k = 0; k < 1; k++) begin : g
    assign b.d[0+:4] = x;
  end
  assign b.d[7:4] = '0;
  assign o = b.d;
endmodule
