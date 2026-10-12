// § nestedDefPortsNeedShell297
interface ifc; logic [1:0] d; function automatic logic [1:0] g(); return d; endfunction endinterface
module dut(output logic [3:0] o);
  ifc i[1:0]();
  for (genvar k = 0; k < 2; k++) begin : g
    assign i[k].d = 2'(k);
  end
  assign o = {i[1].g(), i[0].g()};
endmodule
