// § varInitOpCastKept404
interface ifc;
  int q = 3 - 1;
endinterface
module top;
  ifc u();
  if (1) begin : g
    int k = 7 * 3;
  end
  var logic [7:0] v = 2 + 2;
endmodule
