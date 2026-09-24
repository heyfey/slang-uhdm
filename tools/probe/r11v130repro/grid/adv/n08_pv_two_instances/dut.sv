// § portViewParamDefName130
interface bus #(parameter W = 4);
  logic [W-1:0] d;
endinterface
module sub(bus b, output logic [7:0] o);
  assign o = b.d;
endmodule
module top(output logic [7:0] o1, output logic [7:0] o2);
  bus #(.W(8)) b0();
  bus #(.W(2)) b1();
  sub u0(.b(b0), .o(o1));
  sub u1(.b(b1), .o(o2));
endmodule
