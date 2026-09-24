// § portViewParamDefName130
interface bus #(parameter W = 4);
  logic [W-1:0] d;
  modport mp(input d);
endinterface
module sub(bus b, output logic [7:0] o);
  assign o = b.d;
endmodule
module top(output logic [7:0] o);
  bus #(.W(8)) b0();
  sub u(.b(b0.mp), .o(o));
endmodule
