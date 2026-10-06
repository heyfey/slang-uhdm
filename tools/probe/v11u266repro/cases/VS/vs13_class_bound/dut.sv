// § sgnLitElabFreshIntTs266
class C #(int N = 1);
  logic [N-1:0] v;
endclass
module dut (output logic [31:0] o);
  localparam int P = 8'sd4;
  C #(P) c;
  initial c = new;
  assign o = P;
endmodule
