// § sgnLitElabFreshIntTs266
class C #(int N = 8'sh04);
  localparam int M = 8'sh02;
  int v = N + M;
endclass
module dut (output logic [31:0] o);
  C #() c;
  initial c = new;
  assign o = 0;
endmodule
