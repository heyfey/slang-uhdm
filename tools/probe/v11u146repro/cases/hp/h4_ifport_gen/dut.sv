// § constPathBaseAnyKind146
interface bus #(parameter W = 8); logic [W-1:0] d; endinterface
module child(bus b, output logic q);
  if (b.W == 8) begin : g8
    assign q = b.d[0];
  end else begin : gx
    assign q = 1'b0;
  end
endmodule
module top(output logic q);
  bus #(.W(8)) b0();
  child c(.b(b0), .q(q));
endmodule
