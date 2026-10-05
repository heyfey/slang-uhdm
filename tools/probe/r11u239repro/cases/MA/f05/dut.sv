// § modportArgVarFormalTs239
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic valid;
  modport master (output address, output valid);
  modport slave (input address, input valid);
endinterface
module common #(parameter int AW = 8, parameter bit S = 0) (bus_if.slave bif, output logic o, output logic [6:0] o2);
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
    return a2[6:0];
  endfunction
endmodule
module adapter #(parameter int AW = 8) (output logic o, output logic [6:0] o2);
  bus_if #(.AW(AW)) bif ();
  assign bif.address = '0;
  assign bif.valid = 1'b0;
  common #(.AW(AW)) u_common (.bif(bif), .o(o), .o2(o2));
endmodule
module top (output logic o, output logic [6:0] o2);
  adapter #(.AW(8)) u (.o(o), .o2(o2));
endmodule
