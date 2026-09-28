// r11u205 IP i08: an interface-port member's indexed part select as a generate target (Rggen's bit_field_if is a port)
interface bif;
  logic [7:0] d;
  modport m(output d);
endinterface
module sub(bif.m b, input logic [3:0] x);
  if (1) begin : g
    assign b.d[0+:4] = x;
  end
  assign b.d[7:4] = '0;
endmodule
module dut(input logic [3:0] x, output logic [7:0] o);
  bif bb();
  sub u(.b(bb), .x(x));
  assign o = bb.d;
endmodule
