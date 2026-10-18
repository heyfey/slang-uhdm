// § uninstIfaceTdThroughPortSkip402
interface types_if;
  typedef logic [3:0] T;
endinterface
interface a_if(types_if types);
  typedef types.T T;
  T v;
endinterface
interface b_if;
  logic q;
endinterface
module top;
  types_if t();
endmodule
