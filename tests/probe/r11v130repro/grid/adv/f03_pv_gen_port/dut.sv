// § portViewParamDefName130
interface bus #(parameter W = 4);
  logic [W-1:0] d;
endinterface
module sub(bus b, output logic [7:0] o);
  assign o = b.d;
endmodule
module top(output logic [7:0] o0, output logic [7:0] o1);
  for (genvar i = 0; i < 2; i++) begin : g
    bus #(.W(8)) b0();
    if (i == 0) begin : a sub u(.b(b0), .o(o0)); end
    else begin : c sub u(.b(b0), .o(o1)); end
  end
endmodule
