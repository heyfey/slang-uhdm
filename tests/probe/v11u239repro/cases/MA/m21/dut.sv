// § ndaBeforeAssign239v
// net-declaration assignments around an assign statement: wire pb, assign pa, wire pc
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic [AW-1:0] data;
  logic valid;
  modport slave (input address, input data, input valid);
  modport mon (input address, input data, input valid);
endinterface
module adapter (bus_if.slave bif, output logic o, output logic o2, output logic o3);
  wire w = pb(bif.address);
  assign o = pa(bif.address);
  wire w3 = pc(bif.address);
  assign o2 = w;
  assign o3 = w3;
  function automatic logic pa(logic [5:0] a);
    return a == 0;
  endfunction
  function automatic logic pb(logic [3:0] a);
    return a == 0;
  endfunction
  function automatic logic pc(logic [2:0] a);
    return a == 0;
  endfunction
endmodule
module top (output logic o, output logic o2, output logic o3);
  bus_if #(.AW(8)) b ();
  adapter u (.bif(b), .o(o), .o2(o2), .o3(o3));
endmodule
