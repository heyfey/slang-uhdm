// § nestedDefPortsNeedShell297
interface ifc; logic d; endinterface
module c_m(ifc p, output logic o); assign o = p.d; endmodule
module dut(output logic o, q);
  for (genvar k = 0; k < 2; k++) begin : g
    ifc i();
    assign i.d = k[0];
    if (k == 0) begin : a c_m u(.p(i), .o(o)); end
    else begin : b c_m u(.p(i), .o(q)); end
  end
endmodule
