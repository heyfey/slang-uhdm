interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
interface mid_w5 #(parameter int R = 4)(ifc4.host arr[R]);
endinterface
module top;
  ifc4 arr[6]();
  mid_w5 #(.R(6)) u (arr);
endmodule
