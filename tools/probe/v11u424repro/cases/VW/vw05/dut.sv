// § classParamWrittenKwTs424
class C #(int N = 4, bit F = 1'b1);
  localparam bit signed BS = 1;
  localparam logic [3:0] L4 = N;
endclass
module test; C #(5) c; endmodule
