// § trailIdxVarSelNamesByPath278
interface ifc; logic [1:0][3:0] m; logic [31:0] f; endinterface
module top(output logic o);
  ifc i();
  logic [1:0][3:0] m;
  assign o = i.f[m[1][2]];
endmodule
