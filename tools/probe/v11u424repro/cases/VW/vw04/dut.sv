// § classParamWrittenKwTs424
class C;
  parameter A = 2;
  localparam byte unsigned BU = A + 1;
  localparam shortint SH = A - 1;
  localparam integer IN = A << 1;
endclass
module test; endmodule
