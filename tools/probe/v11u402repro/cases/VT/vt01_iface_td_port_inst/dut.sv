// § uninstIfaceTdThroughPortSkip402
interface types_if;
  typedef logic [3:0] T;
endinterface
interface a_if(types_if types);
  typedef types.T T;
  T v;
endinterface
module top;
  types_if t();
  a_if a(t);
endmodule
