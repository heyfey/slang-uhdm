// § hpBaseSelOpIdxNamesByPath145
interface ifc #(parameter int W = 4); logic [W-1:0] d; endinterface
module dut(input logic [7:0] i, output logic [7:0] o);
  localparam int D = 2;
  ifc b[1:0]();
  assign o = i[b[D-1].W:0];
endmodule
