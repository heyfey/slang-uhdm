// § psBoundBareRefByBase145 (control: indexed part-select)
module dut(input logic [31:0] a, input logic [2:0] i, output logic [3:0] o);
  localparam int L = 4;
  assign o = a[i*L +: L];
endmodule
