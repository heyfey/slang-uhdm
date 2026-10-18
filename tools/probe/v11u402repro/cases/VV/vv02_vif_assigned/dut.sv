// § vifVarNotElaborated402
interface I; logic a; endinterface
module top;
  I i0();
  virtual I v;
  initial begin
    v = i0;
    v.a = 1'b1;
  end
endmodule
