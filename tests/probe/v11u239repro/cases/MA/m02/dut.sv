// § modportArgVarFormalTs239
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic [AW-1:0] data;
  logic valid;
  modport slave (input address, input data, input valid);
  modport mon (input address, input data, input valid);
endinterface
module adapter (bus_if.slave bif, output logic [7:0] o);
  assign o[3:0] = pre(bif.address) | 4'h0;
  assign o[7:4] = '0;
  function automatic logic [3:0] pre(logic [5:0] a);
    return a[3:0];
  endfunction
endmodule
module top (output logic [7:0] o);
  bus_if #(.AW(8)) b ();
  adapter u (.bif(b), .o(o));
endmodule
