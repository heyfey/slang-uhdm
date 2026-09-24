// § portViewParamDefName130
interface bus #(parameter W = 4);
  logic [W-1:0] d;
endinterface
module sub(bus b [2], output logic [7:0] o);
  assign o = {b[1].d, b[0].d};
endmodule
module top(output logic [7:0] o);
  bus #(.W(4)) bb[2] ();
  sub u(.b(bb), .o(o));
endmodule
