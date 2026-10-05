// § modportArgVarFormalTs239
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic [AW-1:0] data;
  logic valid;
  modport slave (input address, input data, input valid);
endinterface
module adapter #(parameter int AW = 8) (bus_if.slave bif, output logic o);
  assign o = pre_decode(bif.address + 1);
  function automatic logic pre_decode(logic [AW-1:0] address);
    return address == '0;
  endfunction
  function automatic logic pre_two(logic [AW-2:0] a2);
    return a2 == '0;
  endfunction
endmodule
module top (output logic o);
  bus_if #(.AW(8)) b ();
  adapter #(.AW(8)) u (.bif(b), .o(o));
endmodule
