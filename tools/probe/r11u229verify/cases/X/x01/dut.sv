// § strLitContOwnerEnd224 § ifArrElemLitCaFresh225 (a continued literal onto an interface-array element member)
interface bi;
  logic w;
  logic [3:0] v;
  logic [15:0] h;
endinterface
module top(output logic [15:0] o);
  bi b[2]();
  assign b[1].h = "ab \
c";
  assign o = b[1].h;
endmodule
