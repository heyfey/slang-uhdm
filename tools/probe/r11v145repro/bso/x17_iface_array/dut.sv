// § hpBaseSelOpIdxNamesByPath145
interface ifc;
  logic s;
endinterface
module dut(output logic o);
  localparam D = 2;
  ifc u[D]();
  assign u[0].s = 1'b0;
  assign u[1].s = 1'b1;
  assign o = u[D-1].s;
endmodule
