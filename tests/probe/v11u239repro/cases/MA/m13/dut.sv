// § modportArgVarFormalTs239
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic [AW-1:0] data;
  logic valid;
  modport slave (input address, input data, input valid);
  modport mon (input address, input data, input valid);
endinterface
module adapter (bus_if.slave bif, input logic [5:0] x, output logic o);
  assign o = pre(bif.address) | pre(x);
  function automatic logic pre(logic [5:0] a);
    return a == '0;
  endfunction
endmodule
module top (input logic [5:0] x, output logic o);
  bus_if #(.AW(8)) b ();
  adapter u (.bif(b), .x(x), .o(o));
endmodule
