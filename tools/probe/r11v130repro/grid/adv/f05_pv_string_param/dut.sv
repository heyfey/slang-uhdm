// § portViewParamDefName130
interface bus #(parameter W = 4, parameter logic [3:0] K = 4'h5);
  logic [W-1:0] d;
  assign d = K;
endinterface
module sub(bus b, output logic [3:0] o);
  assign o = b.d ^ b.K;
endmodule
module top(output logic [3:0] o);
  bus #(.K(4'h3)) b0();
  sub u(.b(b0), .o(o));
endmodule
