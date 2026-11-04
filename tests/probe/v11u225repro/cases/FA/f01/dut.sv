// § ifArrElemLitCaFresh225 — fresh: descending array range, two members of one element, a literal and a port side by side
interface bi;
  logic w;
  logic [7:0] v;
endinterface
module dut(input logic i, output logic o, output logic [7:0] q);
  localparam int K = 2;
  bi b[3:0]();
  assign b[K].w = 1'b0;
  assign b[K].v = 8'd17;
  assign b[1].w = i;
  assign o = b[K].w ^ b[1].w;
  assign q = b[K].v;
endmodule
