// § modportArgVarFormalTs239
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic [AW-1:0] data;
  logic valid;
  modport slave (input address, input data, input valid);
  modport mon (input address, input data, input valid);
endinterface
package pk;
  function automatic logic pre(logic [5:0] a);
    return a == '0;
  endfunction
  function automatic logic pre2(logic [2:0] a);
    return a == '0;
  endfunction
endpackage
module adapter (bus_if.slave bif, output logic o, output logic o2);
  import pk::*;
  assign o = pre(bif.address);
  assign o2 = pk::pre2(bif.data[2:0]);
endmodule
module top (output logic o, output logic o2);
  bus_if #(.AW(8)) b ();
  adapter u (.bif(b), .o(o), .o2(o2));
endmodule
