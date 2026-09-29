// § ifArrElemLitCaFresh225 — inside a generate block
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module dut(output logic o);
  localparam int K = 1;
  bi b[2]();
  if (1) begin : g
    assign b[K].w = 1'b1;
  end
  assign o = b[1].w;
endmodule
