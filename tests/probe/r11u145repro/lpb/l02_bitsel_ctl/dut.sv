// § lpPaCopyBoundOwnerName145 (control: bit-select index)
module dut(input logic [31:0] a, input logic [2:0] i, output logic [7:0] o);
  localparam int L = 4;
  if (1) begin : g
    assign o = a[L];
  end
endmodule
