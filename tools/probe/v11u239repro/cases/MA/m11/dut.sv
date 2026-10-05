// § modportArgVarFormalTs239
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic [AW-1:0] data;
  logic valid;
  modport slave (input address, input data, input valid);
  modport mon (input address, input data, input valid);
endinterface
module adapter #(parameter int W = 4) (bus_if.slave bif, output logic o);
  assign o = pre(bif.address);
  function automatic logic pre(logic [W-1:0] a);
    return a == '0;
  endfunction
endmodule
module top (output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    bus_if #(.AW(8)) b ();
    adapter #(.W(3+i)) u (.bif(b), .o(o[i]));
  end
endmodule
