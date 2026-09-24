// § defNetTypeParamDefault137
interface ifc #(parameter type T = logic);
  T d;
endinterface
module top(output logic o);
  ifc i();
  assign o = i.d;
endmodule
