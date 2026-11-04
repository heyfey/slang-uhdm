// § tpArrayElemBindsDefDefault206
module e17 #(parameter type t = struct packed { logic a; logic [1:0] b; }) (input t s, output t o);
  t x [3];
  assign x[0] = s;
  assign o = x[0];
endmodule
