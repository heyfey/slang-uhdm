// § modportArgVarFormalTs239
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic valid;
endinterface
module top (output logic o);
  bus_if #(.AW(8)) b ();
  assign o = pre_decode(b.address);
  function automatic logic pre_decode(logic [7:0] address);
    return address == '0;
  endfunction
endmodule
