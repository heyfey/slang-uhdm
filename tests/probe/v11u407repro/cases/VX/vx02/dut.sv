// § typedParamXzLitSize407
module top(output int o, output logic [3:0] o2, output integer o3);
  parameter bit [3:0] pb = 2'bx1;
  parameter logic [3:0] pl = 8'hxz;
  parameter integer pi = 4'bxxxx;
  assign o = pb;
  assign o2 = pl;
  assign o3 = pi;
endmodule
