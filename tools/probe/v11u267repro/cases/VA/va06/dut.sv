// § caFoldParentUnboundLhs267
module child(output logic [3:0] w);
endmodule
module top #(parameter int W = 4) (output logic [3:0] o);
  child u_c(.w(o));
  assign u_c.w = {W{1'b1}};
endmodule
