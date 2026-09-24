// § unsignedScalarVecTsAtKeyword137
interface bus;
  wire logic unsigned w;
endinterface
module top(output logic o);
  bus b();
  assign o = b.w;
endmodule
