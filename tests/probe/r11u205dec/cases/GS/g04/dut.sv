// r11u205 GS g04: a constant indexed part select of an interface member in a generate-scope instance (Rggen's shape)
interface bif;
  logic [7:0] read_data;
endinterface
module sub(input logic [3:0] i, output logic [3:0] o);
  assign o = i;
endmodule
module top(output logic [3:0] o);
  bif bit_field_if();
  for (genvar k = 0; k < 1; k++) begin : g
    sub u(.i(bit_field_if.read_data[0+:4]), .o(o));
  end
endmodule
