// § constPathBaseAnyKind146
interface bus #(parameter W = 8); logic [W-1:0] d; endinterface
module child(bus b, output logic [7:0] q);
  logic [b.W-1:0] r;
  assign r = b.d; assign q = r;
endmodule
module top(output logic [7:0] q);
  bus #(.W(8)) b0();
  child c(.b(b0), .q(q));
endmodule
