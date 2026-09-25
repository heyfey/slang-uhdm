// § lpPaCopyBoundOwnerName145 (control: a bound nested in an operation keeps the select base)
module dut(input logic [31:0] a, input logic [2:0] i, output logic [7:0] o);
  localparam int L = 4;
  if (1) begin : g
    assign o = a[L-1:0];
  end
endmodule
