interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
program prog_w4 #(parameter int R = 4)(ifc4.host arr[R]);
endprogram
module top;
  ifc4 arr[6]();
  prog_w4 #(.R(6)) u (arr);
endmodule
