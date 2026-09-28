// § modAggClonePerDefKey191: one header typedef included in a module and in an interface, each with a formal writer, the interface instantiated twice inside the module
interface bus(output logic o);
`include "td.svh"
  function automatic logic chk(input ent_t e); return e.v; endfunction
  assign o = chk(4'h1);
endinterface
module mm(output logic o, output logic p, output logic q);
`include "td.svh"
  function automatic logic chk2(input ent_t e); return e.v; endfunction
  assign o = chk2(4'h3);
  bus b1(p);
  bus b2(q);
endmodule
module top(output logic o, p, q);
  mm u(o, p, q);
endmodule
