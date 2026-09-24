// § portViewParamDefName130
interface bus #(parameter W = 4, parameter D = W * 2);
  logic [D-1:0] d;
endinterface
module sub(bus b, output logic [15:0] o);
  assign o = b.d;
endmodule
module top(output logic [15:0] o);
  bus #(.W(8)) b0();
  sub u(.b(b0), .o(o));
endmodule
