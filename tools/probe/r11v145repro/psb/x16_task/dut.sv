// § psBoundBareRefByBase145
module dut(input logic [31:0] a, output logic [4:0] o);
  localparam int W = 8;
  localparam int L = 4;
  task automatic t(output logic [4:0] y);
    y = a[W:L];
  endtask
  always_comb t(o);
endmodule
