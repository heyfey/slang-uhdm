// § rootPathFullNameByChain181 § rootNetPathOwnNames181 (v11u181 break: $root through an interface instance, an instance parameter, inside $bits and a system call argument)
interface ifc; logic sig; logic [3:0] bus; endinterface
module sub #(parameter int W = 4); logic [W-1:0] q; endmodule
module top;
  ifc i0();
  sub #(.W(6)) u();
  logic [7:0] y;
  initial begin
    y = $root.top.i0.bus + $root.top.u.q;
    y = $bits($root.top.u.q);
    $display("%b", $root.top.i0.sig);
  end
endmodule
