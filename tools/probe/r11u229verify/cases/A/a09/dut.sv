// § ifArrElemLitCaFresh225 (a member of an interface instance held by the array element)
interface sub_i;
  logic w;
endinterface
interface bo;
  sub_i sub();
endinterface
module top(output logic o);
  bo b[2]();
  assign b[1].sub.w = 1'b1;
  assign o = b[1].sub.w;
endmodule
