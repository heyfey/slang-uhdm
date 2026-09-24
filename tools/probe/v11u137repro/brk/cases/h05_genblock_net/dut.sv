// § defNetTypeParamDefault137
module bottom #(parameter type T = logic)(output logic o);
  if (1) begin : g
    T d;
    assign d = 1'b1;
  end
  assign o = g.d;
endmodule
module top (output logic o);
  bottom u(.o(o));
endmodule
