// § portViewParamDefName130
interface bus #(parameter W = 4);
  logic [W-1:0] d;
endinterface
module sub #(parameter W = 3) (bus b, output logic [W-1:0] o);
  assign o = b.d[W-1:0];
endmodule
module top(output logic [2:0] o);
  bus #(.W(6)) b0();
  sub #(.W(3)) u(.b(b0), .o(o));
endmodule
