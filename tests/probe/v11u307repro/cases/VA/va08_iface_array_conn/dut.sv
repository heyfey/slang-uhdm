// § genScopeModArrayElems307
interface ifc; logic w; endinterface
module leaf (ifc p, output logic o); assign o = p.w; endmodule
module dut (input logic [1:0] a, output logic [1:0] y);
  ifc u_if [1:0] ();
  assign u_if[0].w = a[0];
  assign u_if[1].w = a[1];
  if (1) begin : g
    leaf u_l [1:0] (.p(u_if), .o(y));
  end
endmodule
