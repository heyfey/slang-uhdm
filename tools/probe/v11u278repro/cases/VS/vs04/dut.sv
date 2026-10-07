// § trailIdxVarSelNamesByPath278
interface bi; logic [31:0] f; endinterface
module sub(bi b, output logic o, input logic [1:0][3:0] m);
  assign o = b.f[m[1][2]];
endmodule
module top(output logic o, input logic [1:0][3:0] m);
  bi b();
  sub s(.b(b), .o(o), .m(m));
endmodule
