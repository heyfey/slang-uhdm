// § modportArgVarFormalTs239
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic [AW-1:0] data;
  logic valid;
  modport slave (input address, input data, input valid);
  modport mon (input address, input data, input valid);
endinterface
module adapter (bus_if.slave bif, output logic o1, output logic [2:0] o2);
  assign {o1, o2} = pre(bif.address);
  function automatic logic [3:0] pre(logic [5:0] a);
    return a[3:0];
  endfunction
endmodule
module top (output logic o1, output logic [2:0] o2);
  bus_if #(.AW(8)) b ();
  adapter u (.bif(b), .o1(o1), .o2(o2));
endmodule
