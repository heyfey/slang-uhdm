// § classParamWrittenKwTs424 (a non-constant initializer of a written int)
class C;
  localparam A = 3;
  parameter int D = A + 1;
  parameter string N = {"a", "b"};
  localparam int E = $bits(longint) / 2;
endclass
module test; endmodule
