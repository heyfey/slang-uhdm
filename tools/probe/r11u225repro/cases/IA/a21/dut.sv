// § ifArrElemLitCaFresh225 — a program-scope-free module array of modules (control: not an interface)
module leaf(input logic w);
endmodule
module dut(output logic o);
  localparam int K = 1;
  logic [1:0] n;
  assign n[K] = 1'b1;
  leaf l[2](.w(n));
  assign o = n[0];
endmodule
