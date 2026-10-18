// § uninstIfaceTdThroughPortSkip402
interface types_if;
  typedef logic [1:0] id_t;
endinterface
interface a_if(types_if types);
  typedef types.id_t id_t;
  id_t x;
  modport m(input x);
endinterface
module top;
  types_if t();
endmodule
