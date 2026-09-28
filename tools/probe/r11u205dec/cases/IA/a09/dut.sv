// r11u205 IA a09: an interface-array port target, the right side a non-constant not reading the genvar
interface bi;
  logic w;
  modport m (output w);
endinterface
module drv (bi.m p [2], input logic x);
  for (genvar i = 0; i < 2; i++) begin : g
    assign p[i].w = x;
  end
endmodule
module dut(input logic x, output logic o);
  bi b[2]();
  drv u (.p(b), .x(x));
  assign o = b[0].w;
endmodule
