// § caLhsBindsUpScopes269 (control: an interface gen scope whose signal no instantiating module declares)
interface ifc #(parameter int W = 4);
  logic [3:0] s;
  if (1) begin : g
    assign s = {W{1'b1}};
  end
endinterface
module top(output logic [3:0] o);
  ifc u_i();
  assign o = u_i.s;
endmodule
