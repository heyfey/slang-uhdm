// § lpPaCopyBoundOwnerName145
interface ifc;
  localparam int L = 2;
  logic [7:0] d;
  logic [5:0] q;
  if (1) begin : g
    assign q = d[7:L];
  end
endinterface
module dut();
  ifc u();
endmodule
