// § genScopeModArrayElems307
interface ib; logic v; endinterface
module leaf (ib b, output logic o); assign o = b.v; endmodule
module dut (output logic [1:0] y);
  ib x ();
  if (1) begin : g
    leaf u_l [1:0] (.b(x), .o(y));
  end
endmodule
