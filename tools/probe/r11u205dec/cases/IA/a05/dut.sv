// r11u205 IA a05: control, an interface-array PORT element member as a generate target (uhdm2rtlil genvar_iface_struct's shape)
interface bi;
  logic w;
  modport m (output w);
endinterface
module drv (bi.m p [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign p[i].w = 1'b1;
  end
endmodule
module dut(output logic o);
  bi b[2]();
  drv u (.p(b));
  assign o = b[0].w;
endmodule
