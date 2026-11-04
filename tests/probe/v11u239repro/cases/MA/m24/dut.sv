// § modportArgVarFormalTs239
// the port passed down: the parent and the child both call through the same modport
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic [AW-1:0] data;
  logic valid;
  modport slave (input address, input data, input valid);
  modport mon (input address, input data, input valid);
endinterface
module leaf (bus_if.slave bif, output logic o);
  assign o = pb(bif.address);
  function automatic logic pa(logic [5:0] a);
    return a == 0;
  endfunction
  function automatic logic pb(logic [3:0] a);
    return a == 0;
  endfunction
  function automatic logic pc(logic [2:0] a);
    return a == 0;
  endfunction
endmodule
module mid (bus_if.slave bif, output logic o, output logic o2);
  assign o = pa(bif.address);
  leaf l (.bif(bif), .o(o2));
  function automatic logic pa(logic [5:0] a);
    return a == 0;
  endfunction
  function automatic logic pb(logic [3:0] a);
    return a == 0;
  endfunction
  function automatic logic pc(logic [2:0] a);
    return a == 0;
  endfunction
endmodule
module top (output logic o, output logic o2);
  bus_if #(.AW(8)) b ();
  mid u (.bif(b), .o(o), .o2(o2));
endmodule
