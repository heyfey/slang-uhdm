// § modportArgVarFormalTs239
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic [AW-1:0] data;
  logic valid;
  modport slave (input address, input data, input valid);
  modport mon (input address, input data, input valid);
endinterface
module adapter #(parameter bit EN = 1) (bus_if.slave bif, output logic o);
  if (EN) begin : g_on
    assign o = pre(bif.address);
  end else begin : g_off
    assign o = 1'b0;
  end
  function automatic logic pre(logic [5:0] a);
    return a == '0;
  endfunction
endmodule
module top (output logic o);
  bus_if #(.AW(8)) b ();
  adapter u (.bif(b), .o(o));
endmodule
