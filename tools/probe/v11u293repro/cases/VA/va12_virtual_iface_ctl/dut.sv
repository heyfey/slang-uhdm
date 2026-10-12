// § defNetClassArrTsDimEnd293
// CONTROL: a virtual interface array (not a class).
interface ifc (); logic x; endinterface
module top;
  ifc u_if ();
  virtual ifc v [2];
  initial v[0] = u_if;
endmodule
