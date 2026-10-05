// § modportArgVarFormalTs239
// CRLF source, the argument written through a macro
`define ADDR(p) p.address
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  modport slave (input address);
endinterface
module adapter #(parameter int AW = 8) (bus_if.slave bif, output logic o);
  assign o = pre_decode(`ADDR(bif));
  function automatic logic pre_decode(logic [AW-1:0] address);
    return address == '0;
  endfunction
endmodule
module top (output logic o);
  bus_if #(.AW(8)) b ();
  adapter #(.AW(8)) u (.bif(b), .o(o));
endmodule
