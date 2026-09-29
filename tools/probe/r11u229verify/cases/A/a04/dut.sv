// § ifArrElemLitCaFresh225 (a string literal onto a vector member)
interface bi;
  logic w;
  logic [3:0] v;
  logic [15:0] h;
endinterface
module top(output logic [15:0] o);
  bi b[2]();
  assign b[1].h = "AB";
  assign o = b[1].h;
endmodule
