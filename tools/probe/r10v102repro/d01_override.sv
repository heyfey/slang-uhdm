module d01_child #(parameter OB = 'b101, parameter OH = 'h1a) ();
endmodule

module d01_dp #(parameter DB = 'b101) ();
endmodule

module d01;
  d01_child #(.OB('hF)) u1();
  d01_child u2();
  d01_child #('hE, 'h2) u3();
  d01_dp u4();
  defparam u4.DB = 'h3;
endmodule
