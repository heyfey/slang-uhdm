// § modportArgVarFormalTs239
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic [AW-1:0] data;
  logic valid;
  modport slave (input address, input data, input valid);
  modport mon (input address, input data, input valid);
endinterface
module adapter (bus_if.slave bif, output logic o);
  assign o = outer(inner(bif.address));
  function automatic logic [3:0] inner(logic [5:0] a);
    return a[3:0];
  endfunction
  function automatic logic outer(logic [3:0] a);
    return a == '0;
  endfunction
endmodule
module top (output logic o);
  bus_if #(.AW(8)) b ();
  adapter u (.bif(b), .o(o));
endmodule
