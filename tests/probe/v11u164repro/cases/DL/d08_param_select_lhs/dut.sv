// § caDelayParamElabFresh164 — a parameter delay onto a bit select
module top #(parameter D = 3) (input a, output [1:0] v);
  assign #D v[0] = a;
  assign v[1] = a;
endmodule
