// § ifaceDynTdElabVar251 (a logic queue typedef variable inside a generate block of an interface)
typedef logic [3:0] q_t [$];
interface ifc;
  if (1) begin : g
    q_t q;
  end
endinterface
module top; ifc i(); endmodule
