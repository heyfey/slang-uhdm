// § modportArgVarFormalTs239
// the assignment target is a modport output; a genvar-indexed member select in a generate loop
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic [AW-1:0] data;
  modport slave (input address, output data);
endinterface
module adapter (bus_if.slave bif, output logic [1:0] o);
  assign bif.data = {7'b0, pre(bif.address)};
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = bit1(bif.address[i]);
  end
  function automatic logic pre(logic [5:0] a);
    return a == 0;
  endfunction
  function automatic logic bit1(logic a);
    return a;
  endfunction
endmodule
module top (output logic [1:0] o);
  bus_if #(.AW(8)) b ();
  adapter u (.bif(b), .o(o));
endmodule
