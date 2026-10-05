// § modportArgVarFormalTs239
// the interface member a wire of a package struct type, the formal the struct typedef
package pk;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } s_t;
  typedef logic [7:0] w_t;
  function automatic logic f(s_t s);
    return s.hi == s.lo;
  endfunction
  function automatic logic g(w_t w);
    return w == 0;
  endfunction
endpackage
interface bus_if;
  wire pk::s_t sw;
  logic [7:0] lv;
  modport slave (input sw, input lv);
endinterface
module adapter (bus_if.slave bif, output logic o, output logic o2);
  assign o = pk::f(bif.sw);
  assign o2 = pk::g(bif.lv);
endmodule
module top (output logic o, output logic o2);
  bus_if b ();
  adapter u (.bif(b), .o(o), .o2(o2));
endmodule
