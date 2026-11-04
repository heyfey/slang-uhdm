// § modportArgVarFormalTs239
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic [AW-1:0] data;
  logic valid;
  modport slave (input address, input data, input valid);
  modport mon (input address, input data, input valid);
endinterface
module adapter (bus_if.slave bif, output logic o);
  assign o = chk(.b(bif.address), .a(bif.data));
  function automatic logic chk(logic [3:0] a, logic [5:0] b);
    return a == '0 && b == '0;
  endfunction
endmodule
module top (output logic o);
  bus_if #(.AW(8)) b ();
  adapter u (.bif(b), .o(o));
endmodule
