// § nestedDefPortsNeedShell297
interface ifc #(parameter int W = 1); logic [W-1:0] d; endinterface
module dut(output logic [3:0] o, output logic p);
  ifc #(.W(4)) a();
  ifc b();
  assign a.d = 4'h3; assign b.d = 1'b1;
  assign o = a.d; assign p = b.d;
endmodule
