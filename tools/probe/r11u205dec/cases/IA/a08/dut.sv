// r11u205 IA a08: an interface-array port target, the right side reading the genvar (iface_array_modport_drive's shape)
interface bi;
  logic w;
  modport m (output w);
endinterface
module drv (bi.m p [2], input logic [1:0] x);
  for (genvar i = 0; i < 2; i++) begin : g
    assign p[i].w = x[i];
  end
endmodule
module dut(input logic [1:0] x, output logic o);
  bi b[2]();
  drv u (.p(b), .x(x));
  assign o = b[0].w;
endmodule
