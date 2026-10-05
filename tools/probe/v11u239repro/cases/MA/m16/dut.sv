// § modportArgVarFormalTs239
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic [AW-1:0] data;
  logic valid;
  modport slave (input address, input data, input valid);
  modport mon (input address, input data, input valid);
endinterface
module adapter (bus_if.slave bif, output logic o);
  assign o = pre(bif.address);
  function automatic logic pre(logic [5:0] a);
    return a == '0;
  endfunction
endmodule
module top (output logic [1:0] o);
  bus_if #(.AW(8)) b [2] ();
  adapter u0 (.bif(b[0]), .o(o[0]));
  adapter u1 (.bif(b[1]), .o(o[1]));
endmodule
