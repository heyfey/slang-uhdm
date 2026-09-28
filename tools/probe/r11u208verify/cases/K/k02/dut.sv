// § modGenericClassListedAtDefault200
interface ifc;
  class ib #(int W = 1);
    logic [W-1:0] q;
  endclass
  ib #(2) h;
endinterface
module sub;
  if (1) begin : g
    class gb #(type T = int);
      T v;
    endclass
    gb #(byte) b;
  end
endmodule
module top;
  ifc i ();
  sub s ();
endmodule
