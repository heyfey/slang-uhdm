// § defNetTypeParamDefault137
interface ifc #(parameter type T = logic);
  T v;
endinterface
module top ();
  ifc #(.T(int)) u();
endmodule
