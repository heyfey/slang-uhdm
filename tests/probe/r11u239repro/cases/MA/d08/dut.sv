// § modportArgVarFormalTs239
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic valid;
  modport slave (input address, input valid);
endinterface
package pk;
  function automatic logic pre_decode(logic [7:0] address);
    return address == '0;
  endfunction
endpackage
module adapter (bus_if.slave bif, output logic o);
  assign o = pk::pre_decode(bif.address);
endmodule
module top (output logic o);
  bus_if #(.AW(8)) b ();
  adapter u (.bif(b), .o(o));
endmodule
