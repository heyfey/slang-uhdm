// § modportArgVarFormalTs239
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic [AW-1:0] data;
  logic valid;
  modport slave (input address, input data, input valid);
endinterface
module adapter #(parameter int AW = 8, parameter bit S = 0) (bus_if.slave bif, output logic o, output logic [6:0] o2);
  assign o = pre_decode(bif.address);
  if (S) begin : g1
    assign o2 = 0;
  end else begin : g
    assign o2 = pre_two(bif.address);
  end
  function automatic logic pre_decode(logic [AW-1:0] address);
    return address == '0;
  endfunction
  function automatic logic [6:0] pre_two(logic [AW-1:0] a2);
    logic [AW-1:0] l;
    if (a2[0] == '0) begin
      l = a2;
    end else begin
      l = a2 - 1;
    end
    return l[0+:7];
  endfunction
endmodule
module top (output logic o, output logic [6:0] o2);
  bus_if #(.AW(8)) b ();
  adapter #(.AW(8)) u (.bif(b), .o(o), .o2(o2));
endmodule
