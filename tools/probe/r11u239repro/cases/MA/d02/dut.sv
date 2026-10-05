// § modportArgVarFormalTs239
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic valid;
  modport slave (input address, input valid);
endinterface
module adapter #(parameter int AW = 8) (bus_if.slave bif, input logic [AW-1:0] pa, output logic o);
  logic [AW-1:0] la;
  assign la = pa;
  assign o = pre_decode(la);
  function automatic logic pre_decode(logic [AW-1:0] address);
    return address == '0;
  endfunction
endmodule
module top (input logic [7:0] pa, output logic o);
  bus_if #(.AW(8)) b ();
  adapter #(.AW(8)) u (.bif(b), .pa(pa), .o(o));
endmodule
