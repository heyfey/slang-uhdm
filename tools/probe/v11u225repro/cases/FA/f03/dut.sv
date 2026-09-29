// § ifArrElemLitCaFresh225 — fresh: a parameterized interface array, the selector a module parameter
interface bi #(parameter int W = 4);
  logic [W-1:0] v;
endinterface
module dut #(parameter int P = 1) (output logic [7:0] q);
  bi #(.W(8)) b[2]();
  assign b[P].v = 8'hA5;
  assign q = b[P].v;
endmodule
