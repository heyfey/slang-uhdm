// § modportArgOwnBodyFn239v
// a hierarchical call into a child instance's function beside the module's own same-named function
interface bus_if;
  logic [7:0] address;
  modport slave (input address);
endinterface
module child (output logic o);
  assign o = 1'b0;
  function automatic logic chk(logic [1:0] a);
    return a == 0;
  endfunction
endmodule
module adapter (bus_if.slave bif, output logic o, output logic o2);
  child c (.o(o2));
  assign o = c.chk(bif.address);
  function automatic logic chk(logic [5:0] a);
    return a == 0;
  endfunction
endmodule
module top (output logic o, output logic o2);
  bus_if b ();
  adapter u (.bif(b), .o(o), .o2(o2));
endmodule
