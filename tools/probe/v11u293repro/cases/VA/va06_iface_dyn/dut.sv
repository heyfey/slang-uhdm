// § defNetClassArrTsDimEnd293
// An interface class handle dynamic array.
class C; int x; endclass
interface ifc ();
  C h [];
  int n;
  initial begin h = new[3]; n = h.size(); end
endinterface
module top;
  ifc u_if ();
endmodule
